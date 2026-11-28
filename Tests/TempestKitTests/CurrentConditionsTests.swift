//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct CurrentConditionsTests {

    private static let payload = """
        {
          "latitude": 37.77493,
          "longitude": -122.41942,
          "timezone": "America/Los_Angeles",
          "location_name": "Test Station",
          "current_conditions": {
            "time": 1791491452,
            "conditions": "Clear",
            "icon": "clear-day",
            "air_temperature": 42.5,
            "sea_level_pressure": 1007.1,
            "station_pressure": 993.1,
            "pressure_trend": "rising",
            "relative_humidity": 16,
            "precip_probability": 20,
            "wind_avg": 0.1,
            "wind_direction": 122,
            "wind_direction_cardinal": "ESE",
            "wind_direction_icon": "east",
            "wind_gust": 1.1,
            "solar_radiation": 802,
            "uv": 8.88,
            "brightness": 96294,
            "feels_like": 41.0,
            "dew_point": 12.0,
            "wet_bulb_temperature": 18.0,
            "wet_bulb_globe_temperature": 26.0,
            "delta_t": 24.5,
            "air_density": 1.08,
            "lightning_strike_count_last_1hr": 3,
            "lightning_strike_count_last_3hr": 7,
            "lightning_strike_last_distance": 12,
            "lightning_strike_last_distance_msg": "7 miles",
            "lightning_strike_last_epoch": 1791490000,
            "precip_accum_local_day": 0.0,
            "precip_accum_local_yesterday": 1.2,
            "precip_minutes_local_day": 0,
            "precip_minutes_local_yesterday": 20,
            "is_precip_local_day_rain_check": true,
            "is_precip_local_yesterday_rain_check": false,
            "includes_station_data": true
          },
          "forecast": {
            "hourly": [{"time": 1791496800, "air_temperature": 41.0}],
            "daily": [{"day_start_local": 1791490800, "air_temp_high": 41.0}]
          }
        }
        """

    @Test("A forecast includes current conditions and location")
    func mapping() throws {
        let response = try JSONDecoder().decode(BetterForecastResponseDTO.self, from: Data(Self.payload.utf8))
        let forecast = TempestForecast(dto: response, units: .metric)

        #expect(forecast.locationName == "Test Station")
        #expect(forecast.timeZone?.identifier == "America/Los_Angeles")
        #expect(forecast.hours.count == 1)

        let now = try #require(forecast.currentConditions)
        #expect(now.timestamp == Date(timeIntervalSince1970: 1_791_491_452))
        #expect(now.conditions == "Clear")
        #expect(now.icon == .clearDay)
        #expect(now.airTemperature == 42.5)
        #expect(now.pressureTrend == .rising)
        #expect(now.precipitationChance == 20)
        #expect(now.windDirectionCardinal == .eastSoutheast)
        #expect(now.feelsLike == 41.0)
        #expect(now.wetBulbGlobe == 26.0)
        #expect(now.deltaT == 24.5)
        #expect(now.airDensity == 1.08)
        #expect(now.lightningStrikeCountLastHour == 3)
        #expect(now.lightningStrikeCountLastThreeHours == 7)
        #expect(now.lightningStrikeLastDistanceMessage == "7 miles")
        #expect(now.lightningStrikeLastTime == Date(timeIntervalSince1970: 1_791_490_000))
        #expect(now.precipitationYesterday == 1.2)
        #expect(now.precipitationMinutesYesterday == 20)
        #expect(now.precipitationTodayIsRainCheck == true)
        #expect(now.precipitationYesterdayIsRainCheck == false)
        #expect(now.includesStationData == true)
    }

    @Test("Current conditions without a time are skipped")
    func missingTime() throws {
        let payload = """
            {"current_conditions": {"conditions": "Clear"}, "forecast": {"hourly": [], "daily": []}}
            """
        let response = try JSONDecoder().decode(BetterForecastResponseDTO.self, from: Data(payload.utf8))
        let forecast = TempestForecast(dto: response, units: .metric)

        #expect(forecast.currentConditions == nil)
        #expect(forecast.locationName == nil)
        #expect(forecast.timeZone == nil)
    }

    @Test("An unknown pressure trend is not the same as a missing one")
    func unknownTrend() throws {
        let payload = """
            {"current_conditions": {"time": 1791491452, "pressure_trend": "unknown"}}
            """
        let response = try JSONDecoder().decode(BetterForecastResponseDTO.self, from: Data(payload.utf8))
        let forecast = TempestForecast(dto: response, units: .metric)

        #expect(forecast.currentConditions?.pressureTrend == .unknown)
    }
}
