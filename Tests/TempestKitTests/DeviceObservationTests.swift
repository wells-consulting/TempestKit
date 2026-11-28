//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct DeviceObservationTests {

    // The row from the UDP reference, 18 values.
    private static let tempest: [Double?] = [
        1_588_948_614, 0.18, 0.22, 0.27, 144, 6, 1017.57, 22.37, 50.26, 328,
        0.03, 3, 0.0, 0, 0, 0, 2.410, 1,
    ]

    // The longer row from the WebSocket and REST docs, 22 values.
    private static let longTempest: [Double?] = [
        1_603_481_377, 0, 0.09, 0.54, 33, 6, 1014.8, 28.8, 71, 16_639,
        1.83, 139, 0, 0, 0, 0, 2.42, 1, 0.07615, 0.5, 0.25, 1,
    ]

    private static let air: [Double?] = [
        1_493_164_835, 835.0, 10.0, 45, 0, 0, 3.46, 1,
    ]

    private static let sky: [Double?] = [
        1_493_321_340, 9000, 10, 0.0, 2.6, 4.6, 7.4, 187, 3.12, 1, 130, nil, 0, 3,
    ]

    private static let longSky: [Double?] = [
        1_493_321_340, 9000, 10, 0.0, 2.6, 4.6, 7.4, 187, 3.12, 1, 130,
        1.034, 0, 3, 0.0, 1.011, 1,
    ]

    @Test("A Tempest row maps every field")
    func tempestMapping() throws {
        let observation = try #require(DeviceObservation(row: Self.tempest, type: .tempest))

        #expect(observation.deviceType == .tempest)
        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_588_948_614))
        #expect(observation.reportInterval == 1)
        #expect(observation.windSampleInterval == 6)
        #expect(observation.windLull == 0.18)
        #expect(observation.windAverage == 0.22)
        #expect(observation.windGust == 0.27)
        #expect(observation.windDirection == 144)
        #expect(observation.stationPressure == 1017.57)
        #expect(observation.airTemperature == 22.37)
        #expect(observation.relativeHumidity == 50.26)
        #expect(observation.illuminance == 328)
        #expect(observation.uvIndex == 0.03)
        #expect(observation.solarRadiation == 3)
        #expect(observation.precipitation == 0)
        #expect(observation.precipitationType == .noPrecipitation)
        #expect(observation.lightningStrikeCount == 0)
        #expect(observation.lightningStrikeDistance == 0)
        #expect(observation.batteryVoltage == 2.410)
        #expect(observation.localDayPrecipitation == nil)
        #expect(observation.nearcastPrecipitation == nil)
        #expect(observation.precipitationAnalysis == nil)
    }

    @Test("A long Tempest row adds local day rain, NearCast rain and analysis")
    func longTempestMapping() throws {
        let observation = try #require(DeviceObservation(row: Self.longTempest, type: .tempest))

        #expect(observation.localDayPrecipitation == 0.07615)
        #expect(observation.nearcastPrecipitation == 0.5)
        #expect(observation.nearcastLocalDayPrecipitation == 0.25)
        #expect(observation.precipitationAnalysis == .rainCheckShown)
    }

    @Test("An Air row has pressure and temperature but no wind")
    func airMapping() throws {
        let observation = try #require(DeviceObservation(row: Self.air, type: .air))

        #expect(observation.deviceType == .air)
        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_493_164_835))
        #expect(observation.stationPressure == 835)
        #expect(observation.airTemperature == 10)
        #expect(observation.relativeHumidity == 45)
        #expect(observation.lightningStrikeCount == 0)
        #expect(observation.lightningStrikeDistance == 0)
        #expect(observation.batteryVoltage == 3.46)
        #expect(observation.reportInterval == 1)
        #expect(observation.windAverage == nil)
        #expect(observation.illuminance == nil)
        #expect(observation.precipitation == nil)
    }

    @Test("A Sky row has wind and light but no temperature")
    func skyMapping() throws {
        let observation = try #require(DeviceObservation(row: Self.sky, type: .sky))

        #expect(observation.deviceType == .sky)
        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_493_321_340))
        #expect(observation.illuminance == 9000)
        #expect(observation.uvIndex == 10)
        #expect(observation.solarRadiation == 130)
        #expect(observation.precipitation == 0)
        #expect(observation.localDayPrecipitation == nil)
        #expect(observation.precipitationType == .noPrecipitation)
        #expect(observation.windLull == 2.6)
        #expect(observation.windAverage == 4.6)
        #expect(observation.windGust == 7.4)
        #expect(observation.windDirection == 187)
        #expect(observation.windSampleInterval == 3)
        #expect(observation.batteryVoltage == 3.12)
        #expect(observation.reportInterval == 1)
        #expect(observation.airTemperature == nil)
        #expect(observation.stationPressure == nil)
        #expect(observation.nearcastPrecipitation == nil)
        #expect(observation.precipitationAnalysis == nil)
    }

    @Test("A long Sky row adds NearCast rain and analysis")
    func longSkyMapping() throws {
        let observation = try #require(DeviceObservation(row: Self.longSky, type: .sky))

        #expect(observation.localDayPrecipitation == 1.034)
        #expect(observation.nearcastPrecipitation == 0)
        #expect(observation.nearcastLocalDayPrecipitation == 1.011)
        #expect(observation.precipitationAnalysis == .rainCheckShown)
    }

    @Test("A row without a timestamp is dropped")
    func missingTimestamp() {
        var row = Self.tempest
        row[0] = nil
        #expect(DeviceObservation(row: row, type: .tempest) == nil)
    }

    @Test("A device row without a temperature still maps")
    func missingTemperature() throws {
        var row = Self.tempest
        row[7] = nil
        let observation = try #require(DeviceObservation(row: row, type: .tempest))
        #expect(observation.airTemperature == nil)
        #expect(observation.stationPressure == 1017.57)
    }

    @Test("A Tempest reading maps to a station observation")
    func stationMapping() throws {
        let device = try #require(DeviceObservation(row: Self.longTempest, type: .tempest))
        let observation = try #require(StationObservation(device, stationID: 42))

        #expect(observation.stationID == 42)
        #expect(observation.timestamp == device.timestamp)
        #expect(observation.airTemperature == 28.8)
        #expect(observation.seaLevelPressure == nil)
        #expect(observation.windSampleInterval == 6)
        #expect(observation.batteryVoltage == 2.42)
        #expect(observation.precipitationAnalysis == .rainCheckShown)
        #expect(observation.nearcastPrecipitation == 0.5)
    }

    @Test("An Air or Sky reading doesn't map to a station observation")
    func nonTempestStationMapping() throws {
        let air = try #require(DeviceObservation(row: Self.air, type: .air))
        let sky = try #require(DeviceObservation(row: Self.sky, type: .sky))

        #expect(StationObservation(air, stationID: 1) == nil)
        #expect(StationObservation(sky, stationID: 1) == nil)
    }

    @Test("Each row type knows its device")
    func rowTypes() {
        #expect(DeviceObservation.RowType.tempest.deviceType == .tempest)
        #expect(DeviceObservation.RowType.air.deviceType == .air)
        #expect(DeviceObservation.RowType.sky.deviceType == .sky)
    }
}
