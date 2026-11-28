//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import TempestKit

// Turns one WebSocket text message into events. Internal so tests can hand it
// saved messages without a socket.
struct WebSocketEventParser: Sendable {

    func parse(_ text: String) -> [TempestWebSocketEvent] {
        guard let data = text.data(using: .utf8) else { return [] }

        let message: Message
        do {
            message = try JSONDecoder().decode(Message.self, from: data)
        } catch {
            // A strange message isn't worth reporting. Another one is coming.
            return []
        }

        switch message.type {
        case "ack":
            guard let id = message.id?.value else { return [] }
            return [.acknowledged(id: id)]

        case "obs_st", "obs_air", "obs_sky":
            guard
                let deviceID = message.deviceID,
                let rowType = DeviceObservation.RowType(rawValue: message.type)
            else {
                return []
            }
            return (message.obs ?? []).compactMap { row in
                DeviceObservation(row: row, type: rowType)
                    .map { .observation(deviceID: deviceID, observation: $0) }
            }

        case "rapid_wind":
            guard
                let deviceID = message.deviceID,
                let row = message.ob,
                row.count >= 3,
                let timestamp = row[0],
                let speed = row[1],
                let direction = row[2]
            else {
                return []
            }
            return [
                .rapidWind(
                    deviceID: deviceID,
                    timestamp: Date(timeIntervalSince1970: timestamp),
                    speed: speed,
                    direction: direction
                )
            ]

        case "evt_strike":
            guard
                let deviceID = message.deviceID,
                let row = message.evt,
                row.count >= 3,
                let timestamp = row[0],
                let distance = row[1],
                let energy = row[2]
            else {
                return []
            }
            return [
                .lightningStrike(
                    deviceID: deviceID,
                    timestamp: Date(timeIntervalSince1970: timestamp),
                    distance: distance,
                    energy: energy
                )
            ]

        case "evt_precip":
            guard let deviceID = message.deviceID else { return [] }
            return [.rainStart(deviceID: deviceID)]

        case "geo_strike":
            guard
                let time = message.time,
                let latitude = message.latitude,
                let longitude = message.longitude
            else {
                return []
            }
            return [
                .geoStrike(
                    time: Date(timeIntervalSince1970: time),
                    latitude: latitude,
                    longitude: longitude,
                    magnitude: message.magnitude,
                    strikeType: message.strikeType.map(StrikeType.init(rawValue:))
                )
            ]

        default:
            // Anything newer
            return []
        }
    }

    // The WebSocket envelope. Each message type uses only some of these keys.
    struct Message: Decodable, Sendable {

        let type: String
        let deviceID: Int?
        let id: FlexibleText?
        let obs: [[Double?]]?
        let ob: [Double?]?
        let evt: [Double?]?
        let time: Double?
        let latitude: Double?
        let longitude: Double?
        let magnitude: Int?
        let strikeType: String?

        private enum CodingKeys: String, CodingKey {
            case type
            case deviceID = "device_id"
            case id
            case obs
            case ob
            case evt
            case time
            case latitude = "lat"
            case longitude = "lon"
            case magnitude = "mag"
            case strikeType = "strike_type"
        }
    }
}

/// The ack id can be a string or a number.
struct FlexibleText: Decodable, Sendable {

    let value: String

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            value = try container.decode(String.self)
        } catch {
            value = String(try container.decode(Int.self))
        }
    }
}
