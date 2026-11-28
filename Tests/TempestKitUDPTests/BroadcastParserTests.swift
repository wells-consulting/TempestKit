//
// TempestKitUDP
// Copyright 2026 Wells Consulting. MIT licensed.
//

#if canImport(Network)
import Foundation
import Testing

import TempestKit

@testable import TempestKitUDP

struct BroadcastParserTests {

    private let parser = BroadcastParser(stationID: 42, hubSerialNumber: "HB-00000001")

    // Real broadcasts from a Tempest, with the serials replaced. This obs_st
    // row has 18 values, which is what firmware 193 sends: no local day rain.
    private static let obsSt = #"{"serial_number":"ST-00000000","type":"obs_st","hub_sn":"HB-00000001","obs":[[1795042888,0.00,0.69,1.50,157,3,1006.38,22.02,25.30,26415,1.42,220,0.000000,0,0,0,2.781,1]],"firmware_revision":193}"#

    // The same message with the extra fields newer firmware sends: local day
    // rain at 18, NearCast rain at 19, and local day NearCast rain at 20.
    private static let longObsSt = #"{"serial_number":"ST-00000000","type":"obs_st","hub_sn":"HB-00000001","obs":[[1795042888,0.00,0.69,1.50,157,3,1006.38,22.02,25.30,26415,1.42,220,0.000000,0,0,0,2.781,1,1.25,2,3.5]]}"#

    private static let obsAir = #"{"serial_number":"AR-00004049","type":"obs_air","hub_sn":"HB-00000001","obs":[[1493164835,835.0,10.0,45,0,0,3.46,1]],"firmware_revision":17}"#

    private static let obsSky = #"{"serial_number":"SK-00008453","type":"obs_sky","hub_sn":"HB-00000001","obs":[[1493321340,9000,10,0.0,2.6,4.6,7.4,187,3.12,1,130,null,0,3]],"firmware_revision":29}"#

    private static let rapidWind = #"{"serial_number":"ST-00000000","type":"rapid_wind","hub_sn":"HB-00000001","ob":[1795042833,0.69,171]}"#

    private static let strike = #"{"serial_number":"ST-00000000","type":"evt_strike","hub_sn":"HB-00000001","ev":[1795042840,12.5,4200]}"#

    private static let rainStart = #"{"serial_number":"ST-00000000","type":"evt_precip","hub_sn":"HB-00000001","ev":[1795042850]}"#

    private static let deviceStatus = #"{"serial_number":"ST-00000000","type":"device_status","hub_sn":"HB-00000001","timestamp":1795042888,"uptime":3562722,"voltage":2.781,"firmware_revision":193,"rssi":-46,"hub_rssi":-43,"sensor_status":0,"debug":1,"sonic_fw":"5.1"}"#

    private static let deviceStatusFlags = #"{"serial_number":"ST-00000000","type":"device_status","hub_sn":"HB-00000001","timestamp":1795042888,"sensor_status":3}"#

    private static let hubStatus = #"{"serial_number":"HB-00000001","type":"hub_status","firmware_revision":"35","uptime":1670133,"rssi":-62,"timestamp":1495724691,"reset_flags":"BOR,PIN,POR","seq":48,"fs":[1,0,15675411,524288],"radio_stats":[2,1,0,3,2839],"mqtt_stats":[1,0]}"#

    @Test("An obs_st row maps every field the broadcast sends")
    func observationMapping() throws {
        let broadcasts = parser.parse(Data(Self.obsSt.utf8))
        #expect(broadcasts.count == 1)

        let observation = try #require(broadcasts.first?.observation)
        #expect(observation.stationID == 42)
        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_795_042_888))
        #expect(observation.windLull == 0.0)
        #expect(observation.windAverage == 0.69)
        #expect(observation.windGust == 1.50)
        #expect(observation.windDirection == 157)
        #expect(observation.windSampleInterval == 3)
        #expect(observation.reportInterval == 1)
        #expect(observation.stationPressure == 1006.38)
        #expect(observation.airTemperature == 22.02)
        #expect(observation.relativeHumidity == 25.30)
        #expect(observation.illuminance == 26415)
        #expect(observation.uvIndex == 1.42)
        #expect(observation.solarRadiation == 220)
        #expect(observation.precipitation == 0.0)
        #expect(observation.precipitationType == .noPrecipitation)
        #expect(observation.lightningStrikeCount == 0)
        #expect(observation.batteryVoltage == 2.781)
        #expect(observation.firmwareRevision == "193")
        #expect(observation.hubSerialNumber == "HB-00000001")

        // The broadcast doesn't send these
        #expect(observation.seaLevelPressure == nil)
        #expect(observation.localDayPrecipitation == nil)
        #expect(observation.nearcastPrecipitation == nil)
    }

    @Test("The extra rain fields come through when the firmware sends them")
    func longRow() throws {
        let broadcasts = parser.parse(Data(Self.longObsSt.utf8))
        let observation = try #require(broadcasts.first?.observation)
        #expect(observation.localDayPrecipitation == 1.25)
        #expect(observation.nearcastPrecipitation == 2)
        #expect(observation.nearcastLocalDayPrecipitation == 3.5)
    }

    @Test("A row without a temperature is dropped, not zeroed")
    func missingTemperature() {
        let json = #"{"serial_number":"ST-00000000","type":"obs_st","hub_sn":"HB-00000001","obs":[[1795042888,0,0,0,157,3,1006.38,null,25.30]]}"#
        #expect(parser.parse(Data(json.utf8)).isEmpty)
    }

    @Test("Another hub's broadcast is ignored")
    func otherHub() {
        let json = #"{"serial_number":"ST-00000000","type":"rapid_wind","hub_sn":"HB-99999999","ob":[1795042833,0.69,171]}"#
        #expect(parser.parse(Data(json.utf8)).isEmpty)
    }

    @Test("An Air broadcast maps its own row")
    func airMapping() throws {
        let broadcasts = parser.parse(Data(Self.obsAir.utf8))
        let broadcast = try #require(broadcasts.first)

        guard case .airObservation(let serialNumber, let observation) = broadcast else {
            Issue.record("Expected an Air observation, got \(broadcast)")
            return
        }
        #expect(serialNumber == "AR-00004049")
        #expect(observation.deviceType == .air)
        #expect(observation.airTemperature == 10)
        #expect(observation.stationPressure == 835)
        #expect(observation.relativeHumidity == 45)
        #expect(observation.batteryVoltage == 3.46)
        #expect(observation.firmwareRevision == "17")
        #expect(observation.hubSerialNumber == "HB-00000001")
        #expect(observation.windAverage == nil)
    }

    @Test("A Sky broadcast maps its own row")
    func skyMapping() throws {
        let broadcasts = parser.parse(Data(Self.obsSky.utf8))
        let broadcast = try #require(broadcasts.first)

        guard case .skyObservation(let serialNumber, let observation) = broadcast else {
            Issue.record("Expected a Sky observation, got \(broadcast)")
            return
        }
        #expect(serialNumber == "SK-00008453")
        #expect(observation.deviceType == .sky)
        #expect(observation.illuminance == 9000)
        #expect(observation.windAverage == 4.6)
        #expect(observation.windDirection == 187)
        #expect(observation.batteryVoltage == 3.12)
        #expect(observation.firmwareRevision == "29")
        #expect(observation.hubSerialNumber == "HB-00000001")
        #expect(observation.airTemperature == nil)
    }

    @Test("rapid_wind uses ob, not obs")
    func rapidWindMapping() throws {
        let broadcasts = parser.parse(Data(Self.rapidWind.utf8))
        let broadcast = try #require(broadcasts.first)
        guard case .rapidWind(let serialNumber, let hubSerialNumber, let timestamp, let speed, let direction) = broadcast else {
            Issue.record("Expected rapid wind, got \(broadcast)")
            return
        }
        #expect(serialNumber == "ST-00000000")
        #expect(hubSerialNumber == "HB-00000001")
        #expect(timestamp == Date(timeIntervalSince1970: 1_795_042_833))
        #expect(speed == 0.69)
        #expect(direction == 171)
    }

    @Test("A rapid_wind row that's too short is ignored")
    func shortRapidWind() {
        let json = #"{"serial_number":"ST-00000000","type":"rapid_wind","hub_sn":"HB-00000001","ob":[1795042833,0.69]}"#
        #expect(parser.parse(Data(json.utf8)).isEmpty)
    }

    @Test("A strike has a time, a distance and an energy")
    func strikeMapping() throws {
        let broadcasts = parser.parse(Data(Self.strike.utf8))
        let broadcast = try #require(broadcasts.first)
        guard case .lightningStrike(let serialNumber, let hubSerialNumber, let timestamp, let distance, let energy) = broadcast else {
            Issue.record("Expected a strike, got \(broadcast)")
            return
        }
        #expect(serialNumber == "ST-00000000")
        #expect(hubSerialNumber == "HB-00000001")
        #expect(timestamp == Date(timeIntervalSince1970: 1_795_042_840))
        #expect(distance == 12.5)
        #expect(energy == 4200)
    }

    @Test("Rain start is just a timestamp")
    func rainStartMapping() throws {
        let broadcasts = parser.parse(Data(Self.rainStart.utf8))
        let broadcast = try #require(broadcasts.first)
        guard case .rainStart(let serialNumber, let hubSerialNumber, let date) = broadcast else {
            Issue.record("Expected rain start, got \(broadcast)")
            return
        }
        #expect(serialNumber == "ST-00000000")
        #expect(hubSerialNumber == "HB-00000001")
        #expect(date == Date(timeIntervalSince1970: 1_795_042_850))
    }

    @Test("device_status maps the device's health")
    func deviceStatusMapping() throws {
        let broadcasts = parser.parse(Data(Self.deviceStatus.utf8))
        let broadcast = try #require(broadcasts.first)

        guard case .deviceStatus(let status) = broadcast else {
            Issue.record("Expected a device status, got \(broadcast)")
            return
        }
        #expect(status.serialNumber == "ST-00000000")
        #expect(status.hubSerialNumber == "HB-00000001")
        #expect(status.timestamp == Date(timeIntervalSince1970: 1_795_042_888))
        #expect(status.uptime == 3_562_722)
        #expect(status.voltage == 2.781)
        #expect(status.firmwareRevision == "193")
        #expect(status.rssi == -46)
        #expect(status.hubRSSI == -43)
        #expect(status.sensorStatus.isEmpty)
        #expect(status.debug == true)
        #expect(status.sonicFirmware == "5.1")
    }

    @Test("Sensor problems come through as a set")
    func deviceStatusFlags() throws {
        let broadcasts = parser.parse(Data(Self.deviceStatusFlags.utf8))
        let broadcast = try #require(broadcasts.first)

        guard case .deviceStatus(let status) = broadcast else {
            Issue.record("Expected a device status, got \(broadcast)")
            return
        }
        #expect(status.sensorStatus.contains(.lightningFailed))
        #expect(status.sensorStatus.contains(.lightningNoise))
        #expect(status.sensorStatus.contains(.pressureFailed) == false)
    }

    @Test("hub_status is accepted by its serial number")
    func hubStatusMapping() throws {
        let broadcasts = parser.parse(Data(Self.hubStatus.utf8))
        let broadcast = try #require(broadcasts.first)

        guard case .hubStatus(let status) = broadcast else {
            Issue.record("Expected a hub status, got \(broadcast)")
            return
        }
        #expect(status.serialNumber == "HB-00000001")
        #expect(status.firmwareRevision == "35")
        #expect(status.uptime == 1_670_133)
        #expect(status.rssi == -62)
        #expect(status.timestamp == Date(timeIntervalSince1970: 1_495_724_691))
        #expect(status.resetFlags.contains(.brownout))
        #expect(status.resetFlags.contains(.pin))
        #expect(status.resetFlags.contains(.power))
        #expect(status.resetFlags.contains(.software) == false)
        #expect(status.resetFlagsRaw == "BOR,PIN,POR")
        #expect(status.sequence == 48)
        #expect(status.radioStats?.version == 2)
        #expect(status.radioStats?.rebootCount == 1)
        #expect(status.radioStats?.i2cErrorCount == 0)
        #expect(status.radioStats?.state == .active)
        #expect(status.radioStats?.networkID == 2839)
    }

    @Test("A hub_status without radio stats still maps")
    func hubStatusWithoutRadio() throws {
        let json = #"{"serial_number":"HB-00000001","type":"hub_status","timestamp":1495724691}"#
        let broadcasts = parser.parse(Data(json.utf8))
        let broadcast = try #require(broadcasts.first)

        guard case .hubStatus(let status) = broadcast else {
            Issue.record("Expected a hub status, got \(broadcast)")
            return
        }
        #expect(status.resetFlags.isEmpty)
        #expect(status.resetFlagsRaw == nil)
        #expect(status.radioStats == nil)
    }

    @Test("Another hub's status is ignored")
    func otherHubStatus() {
        let json = #"{"serial_number":"HB-99999999","type":"hub_status","timestamp":1495724691}"#
        #expect(parser.parse(Data(json.utf8)).isEmpty)
    }

    @Test("A packet that isn't JSON is ignored")
    func garbage() {
        #expect(parser.parse(Data("not json".utf8)).isEmpty)
    }
}

private extension TempestBroadcast {

    var observation: StationObservation? {
        if case .observation(_, let observation) = self {
            observation
        } else {
            nil
        }
    }
}
#endif
