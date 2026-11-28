//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct ObservationFieldTests {

    // The real ob_fields names, shuffled
    private static let fields = [
        "air_temp", "timestamp", "wind_avg", "solar_radiation",
    ]
    private static let row: [Double?] = [42.5, 1_791_491_452, 0.1, 802]

    @Test("A row maps by field name, not position")
    func fieldOrder() throws {
        let observation = try #require(
            StationObservation(row: Self.row, fields: Self.fields, stationID: 1)
        )

        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_791_491_452))
        #expect(observation.airTemperature == 42.5)
        #expect(observation.windAverage == 0.1)
        #expect(observation.solarRadiation == 802)
        #expect(observation.stationPressure == nil)
    }

    @Test("An unknown field name is ignored")
    func unknownField() throws {
        let fields = ["timestamp", "air_temp", "brand_new_sensor"]
        let observation = try #require(StationObservation(row: [1_791_491_452, 42.5, 7], fields: fields, stationID: 1))

        #expect(observation.airTemperature == 42.5)
        #expect(observation.relativeHumidity == nil)
    }

    @Test("All the real field names map, in the real order")
    func liveNames() throws {
        let fields = [
            "timestamp", "report_interval", "wind_lull", "wind_avg", "wind_gust",
            "wind_dir", "station_pressure", "sea_level_pressure", "air_temp", "rh",
            "illuminance", "uv", "solar_radiation", "precip_accumulation",
            "local_day_precip_accumulation", "precip_type", "strike_count",
            "strike_distance", "nc_precip_accumulation", "nc_local_day_precip_accumulation",
        ]
        let row: [Double?] = [
            1_791_491_452, 1, 0.0, 0.1, 1.1, 122, 994.9, 1007.1, 42.5, 16,
            96_294, 8.88, 802, 0.0, 0.2, 1, 3, 8.5, 0.3, 1.7,
        ]

        let observation = try #require(StationObservation(row: row, fields: fields, stationID: 1))

        #expect(observation.windDirection == 122)
        #expect(observation.airTemperature == 42.5)
        #expect(observation.relativeHumidity == 16)
        #expect(observation.precipitation == 0.0)
        #expect(observation.localDayPrecipitation == 0.2)
        #expect(observation.precipitationType == .rain)
        #expect(observation.lightningStrikeCount == 3)
        #expect(observation.lightningStrikeDistance == 8.5)
        #expect(observation.nearcastPrecipitation == 0.3)
        #expect(observation.nearcastLocalDayPrecipitation == 1.7)
    }

    @Test("Battery, wind interval and analysis map by name")
    func extraFields() throws {
        let fields = [
            "timestamp", "air_temp", "wind_sample_interval",
            "battery", "precip_analysis_type",
        ]
        let row: [Double?] = [1_791_491_452, 22.5, 3, 2.8, 1]

        let observation = try #require(
            StationObservation(row: row, fields: fields, stationID: 1)
        )
        #expect(observation.windSampleInterval == 3)
        #expect(observation.batteryVoltage == 2.8)
        #expect(observation.precipitationAnalysis == .rainCheckShown)
    }

    @Test("Mapping by name still drops a row without a temperature")
    func missingTemperature() {
        #expect(StationObservation(row: [1_791_491_452], fields: ["timestamp"], stationID: 1) == nil)
    }
}
