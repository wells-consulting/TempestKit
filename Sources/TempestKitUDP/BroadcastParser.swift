//
// TempestKitUDP
// Copyright 2026 Wells Consulting. MIT licensed.
//

#if canImport(Network)
import Foundation
import TempestKit

// Turns one broadcast into the models. Internal so tests can hand it saved
// payloads without a socket.
struct BroadcastParser: Sendable {

    let stationID: WeatherStation.ID
    let hubSerialNumber: String

    func parse(_ data: Data) -> [TempestBroadcast] {
        let message: Message
        do {
            message = try JSONDecoder().decode(Message.self, from: data)
        } catch {
            // A strange packet isn't worth reporting. The hub sends another in
            // a few seconds.
            return []
        }

        // Other hubs on the network broadcast on the same port.
        guard isForHub(message) else { return [] }
        guard let serialNumber = message.serialNumber else { return [] }

        switch message.type {
        case "obs_st":
            return (message.obs ?? []).compactMap { row in
                DeviceObservation(
                    row: row,
                    type: .tempest,
                    firmwareRevision: message.firmwareRevision?.value,
                    hubSerialNumber: message.hubSerialNumber
                )
                .flatMap { StationObservation($0, stationID: stationID) }
                    .map { .observation(serialNumber: serialNumber, observation: $0) }
            }
        case "obs_air":
            return (message.obs ?? []).compactMap { row in
                DeviceObservation(
                    row: row,
                    type: .air,
                    firmwareRevision: message.firmwareRevision?.value,
                    hubSerialNumber: message.hubSerialNumber
                )
                .map { .airObservation(serialNumber: serialNumber, observation: $0) }
            }
        case "obs_sky":
            return (message.obs ?? []).compactMap { row in
                DeviceObservation(
                    row: row,
                    type: .sky,
                    firmwareRevision: message.firmwareRevision?.value,
                    hubSerialNumber: message.hubSerialNumber
                )
                .map { .skyObservation(serialNumber: serialNumber, observation: $0) }
            }
        case "rapid_wind":
            guard let row = message.ob, row.count >= 3,
                  let timestamp = row[0],
                  let speed = row[1],
                  let direction = row[2]
            else { return [] }
            return [
                .rapidWind(
                    serialNumber: serialNumber,
                    hubSerialNumber: message.hubSerialNumber,
                    timestamp: Date(timeIntervalSince1970: timestamp),
                    speed: speed,
                    direction: direction
                )
            ]
        case "evt_strike":
            guard let row = message.ev, row.count >= 3,
                  let timestamp = row[0],
                  let distance = row[1],
                  let energy = row[2]
            else { return [] }
            return [
                .lightningStrike(
                    serialNumber: serialNumber,
                    hubSerialNumber: message.hubSerialNumber,
                    timestamp: Date(timeIntervalSince1970: timestamp),
                    distance: distance,
                    energy: energy
                )
            ]
        case "evt_precip":
            guard let row = message.ev, !row.isEmpty, let timestamp = row[0] else {
                return []
            }
            return [
                .rainStart(
                    serialNumber: serialNumber,
                    hubSerialNumber: message.hubSerialNumber,
                    date: Date(timeIntervalSince1970: timestamp)
                )
            ]
        case "device_status":
            guard let timestamp = message.timestamp else { return [] }
            return [
                .deviceStatus(
                    DeviceStatus(
                        serialNumber: serialNumber,
                        hubSerialNumber: message.hubSerialNumber,
                        timestamp: Date(timeIntervalSince1970: timestamp),
                        uptime: message.uptime,
                        voltage: message.voltage,
                        firmwareRevision: message.firmwareRevision?.value,
                        rssi: message.rssi,
                        hubRSSI: message.hubRSSI,
                        sensorStatus: SensorStatus(rawValue: message.sensorStatus ?? 0),
                        debug: message.debug.map { $0 != 0 },
                        sonicFirmware: message.sonicFirmware
                    )
                )
            ]
        case "hub_status":
            guard let timestamp = message.timestamp else { return [] }
            return [
                .hubStatus(
                    HubStatus(
                        serialNumber: serialNumber,
                        firmwareRevision: message.firmwareRevision?.value,
                        uptime: message.uptime,
                        rssi: message.rssi,
                        timestamp: Date(timeIntervalSince1970: timestamp),
                        resetFlags: ResetFlags(names: message.resetFlags ?? ""),
                        resetFlagsRaw: message.resetFlags,
                        sequence: message.sequence,
                        radioStats: radioStats(from: message.radioStats)
                    )
                )
            ]
        default:
            // Anything newer
            return []
        }
    }

    private func radioStats(from values: [Int?]?) -> RadioStats? {
        guard let values, !values.isEmpty else { return nil }
        func value(at index: Int) -> Int? {
            index < values.count ? values[index] : nil
        }
        return RadioStats(
            version: value(at: 0),
            rebootCount: value(at: 1),
            i2cErrorCount: value(at: 2),
            state: value(at: 3).map(RadioState.init(code:)),
            networkID: value(at: 4)
        )
    }

    // A reading has the hub's serial in hub_sn. A hub_status doesn't send
    // hub_sn; its serial_number is the hub.
    private func isForHub(_ message: Message) -> Bool {
        if message.hubSerialNumber == hubSerialNumber { return true }
        return message.type == "hub_status" && message.serialNumber == hubSerialNumber
    }

    // The hub's envelope. Each message type uses only some of these keys, and
    // a key it doesn't send stays nil.
    struct Message: Decodable, Sendable {

        let type: String
        let serialNumber: String?
        let hubSerialNumber: String?
        let obs: [[Double?]]?
        let ob: [Double?]?
        let ev: [Double?]?
        let timestamp: Double?
        let uptime: Double?
        let voltage: Double?
        let firmwareRevision: FirmwareRevision?
        let rssi: Int?
        let hubRSSI: Int?
        let sensorStatus: Int?
        let debug: Int?
        let sonicFirmware: String?
        let resetFlags: String?
        let sequence: Int?
        let radioStats: [Int?]?

        private enum CodingKeys: String, CodingKey {
            case type
            case serialNumber = "serial_number"
            case hubSerialNumber = "hub_sn"
            case obs
            case ob
            case ev
            case timestamp
            case uptime
            case voltage
            case firmwareRevision = "firmware_revision"
            case rssi
            case hubRSSI = "hub_rssi"
            case sensorStatus = "sensor_status"
            case debug
            case sonicFirmware = "sonic_fw"
            case resetFlags = "reset_flags"
            case sequence = "seq"
            case radioStats = "radio_stats"
        }
    }
}

// The hub sends its firmware revision as a string and a device sends a number.
struct FirmwareRevision: Decodable, Sendable {

    let value: String?

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            value = try container.decode(String.self)
        } catch {
            do {
                value = String(try container.decode(Int.self))
            } catch {
                value = nil
            }
        }
    }
}

#endif
