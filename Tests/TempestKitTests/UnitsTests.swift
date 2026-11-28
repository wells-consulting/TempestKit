//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct UnitsTests {

    @Test("Metric is the API's default set")
    func metric() {
        let units = Units.metric

        #expect(units.temperature == .celsius)
        #expect(units.wind == .metersPerSecond)
        #expect(units.pressure == .millibars)
        #expect(units.precipitation == .millimeters)
        #expect(units.distance == .kilometers)
    }

    @Test("Imperial picks the common US values")
    func imperial() {
        let units = Units.imperial

        #expect(units.temperature == .fahrenheit)
        #expect(units.wind == .milesPerHour)
        #expect(units.pressure == .inchesOfMercury)
        #expect(units.precipitation == .inches)
        #expect(units.distance == .miles)
    }

    @Test("Units become the API's query items")
    func queryItems() {
        let items = Units.imperial.queryItems

        #expect(items.count == 5)
        #expect(items.contains(URLQueryItem(name: "units_temp", value: "f")))
        #expect(items.contains(URLQueryItem(name: "units_wind", value: "mph")))
        #expect(items.contains(URLQueryItem(name: "units_pressure", value: "inhg")))
        #expect(items.contains(URLQueryItem(name: "units_precip", value: "in")))
        #expect(items.contains(URLQueryItem(name: "units_distance", value: "mi")))
    }

    @Test("A station's display units map to the typed values")
    func displayUnits() throws {
        let payload = """
            {
              "station_id": 1,
              "station_units": {
                "units_temp": "f", "units_wind": "mph", "units_precip": "in",
                "units_pressure": "inhg", "units_distance": "mi",
                "units_direction": "cardinal", "units_brightness": "lux",
                "units_solar_radiation": "W/m2", "units_air_density": "lbs/ft3",
                "units_other": "imperial"
              },
              "obs": [{"timestamp": 1791491452}]
            }
            """
        let response = try JSONDecoder().decode(
            StationConditionsResponseDTO.self,
            from: Data(payload.utf8)
        )
        let units = try #require(StationConditions(dto: response)?.displayUnits)

        #expect(units.temperature == .fahrenheit)
        #expect(units.wind == .milesPerHour)
        #expect(units.precipitation == .inches)
        #expect(units.pressure == .inchesOfMercury)
        #expect(units.distance == .miles)
        #expect(units.direction == .cardinal)
        #expect(units.brightness == "lux")
        #expect(units.solarRadiation == "W/m2")
        #expect(units.airDensity == "lbs/ft3")
        #expect(units.other == "imperial")
    }

    @Test("A unit we don't know is nil")
    func unknownUnits() throws {
        let payload = """
            {
              "station_id": 1,
              "station_units": {"units_temp": "kelvin", "units_wind": "warp"},
              "obs": [{"timestamp": 1791491452}]
            }
            """
        let response = try JSONDecoder().decode(
            StationConditionsResponseDTO.self,
            from: Data(payload.utf8)
        )
        let units = try #require(StationConditions(dto: response)?.displayUnits)

        #expect(units.temperature == nil)
        #expect(units.wind == nil)
        #expect(units.pressure == nil)
    }
}
