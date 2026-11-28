//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct ObservationMappingTests {

    // A real /observations/stn row from a hot afternoon:
    // 42.5 °C, 16% humidity, 802 W/m², UV 8.88, no wind.
    private static let row: [Double?] = [
        1_791_491_452, 1, 0.0, 0.1, 1.1, 122, 994.9, 1007.1, 42.5, 16,
        96_294, 8.88, 802, 0.0, 0.0, 0, 0, 0, 0.0, 0.0,
    ]

    @Test("An observation row maps every field")
    func observationMapping() throws {
        let observation = try #require(StationObservation(row: Self.row, stationID: 100_001))
        #expect(observation.stationID == 100_001)
        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_791_491_452))
        #expect(observation.reportInterval == 1)
        #expect(observation.windAverage == 0.1)
        #expect(observation.windGust == 1.1)
        #expect(observation.windDirection == 122)
        #expect(observation.stationPressure == 994.9)
        #expect(observation.seaLevelPressure == 1007.1)
        #expect(observation.airTemperature == 42.5)
        #expect(observation.relativeHumidity == 16)
        #expect(observation.illuminance == 96_294)
        #expect(observation.uvIndex == 8.88)
        #expect(observation.solarRadiation == 802)
        #expect(observation.precipitation == 0.0)
        #expect(observation.precipitationType == .noPrecipitation)
        #expect(observation.lightningStrikeCount == 0)
    }

    @Test("A row without a temperature is dropped, not zeroed")
    func missingTemperature() {
        var row = Self.row
        row[8] = nil
        #expect(StationObservation(row: row, stationID: 1) == nil)
    }

    @Test("A row without a timestamp is dropped, not set to 1970")
    func missingTimestamp() {
        var row = Self.row
        row[0] = nil
        #expect(StationObservation(row: row, stationID: 1) == nil)
    }

    @Test("A short row leaves the missing fields nil")
    func shortRow() throws {
        let observation = try #require(StationObservation(row: [1_791_491_452, 1, 0, 0.1, 1.1, 122, 994.9, 1007.1, 42.5], stationID: 1))
        #expect(observation.airTemperature == 42.5)
        #expect(observation.relativeHumidity == nil)
        #expect(observation.solarRadiation == nil)
        #expect(observation.nearcastLocalDayPrecipitation == nil)
    }

    @Test("Lightning comes before NearCast in the row")
    func fieldOrder() throws {
        var row = Self.row
        row[16] = 2
        row[17] = 8.5
        row[18] = 0.3
        row[19] = 1.7

        let observation = try #require(StationObservation(row: row, stationID: 1))
        #expect(observation.lightningStrikeCount == 2)
        #expect(observation.lightningStrikeDistance == 8.5)
        #expect(observation.nearcastPrecipitation == 0.3)
        #expect(observation.nearcastLocalDayPrecipitation == 1.7)
    }
}
