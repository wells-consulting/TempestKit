//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct ForecastMappingTests {

    // A better_forecast response with three days (a clear one, a rainy one
    // with the chance of rain as a percent, and one missing its low) and one
    // hour. Same shape as the real API, made up numbers.
    private static let fixture = """
        {
            "status": {"status_code": 0, "status_message": "SUCCESS"},
            "latitude": 37.77493,
            "longitude": -122.41942,
            "timezone_offset_minutes": -480,
            "source_id_conditions": 5,
            "build_code": "abc123",
            "refresh_interval_seconds": 900,
            "units": {
                "units_temp": "c", "units_wind": "mps", "units_pressure": "mb",
                "units_precip": "mm", "units_distance": "km",
                "units_brightness": "lux", "units_solar_radiation": "w/m2",
                "units_air_density": "kg/m3", "units_other": "metric"
            },
            "station": {
                "station_id": 100001, "agl": 4.8, "elevation": 100.5,
                "is_station_online": true, "state": 1
            },
            "forecast": {
                "daily": [
                    {"day_start_local": 1791490800, "day_num": 9, "month_num": 10, "conditions": "Clear", "icon": "clear-day", "sunrise": 1791513600, "sunset": 1791556200, "air_temp_high": 41.0, "air_temp_low": 24.0, "air_temp_high_color": "ff4c00", "air_temp_low_color": "afde06", "precip_probability": 0, "precip_icon": "chance-rain", "precip_type": "rain"},
                    {"day_start_local": 1791577200, "day_num": 10, "month_num": 10, "conditions": "Rain Likely", "icon": "rainy", "sunrise": 1791600000, "sunset": 1791642600, "air_temp_high": 28.0, "air_temp_low": 19.0, "precip_probability": 55, "precip_icon": "rain", "precip_type": "rain"},
                    {"day_start_local": 1791663600, "day_num": 11, "month_num": 10, "conditions": "Cloudy", "icon": "cloudy", "air_temp_high": 30.0}
                ],
                "hourly": [
                    {"time": 1791496800, "conditions": "Clear", "icon": "clear-day", "air_temperature": 41.0, "station_pressure": 1006.0, "sea_level_pressure": 1010.0, "precip_probability": 0.05, "precip_icon": "chance-rain", "wind_avg": 3.2, "wind_avg_color": "26fc59", "wind_direction_cardinal": "NNE", "wind_direction_icon": "wind-arrow-w", "wind_gust": 4.5, "wind_gust_color": "ebf100", "uv": 4.1, "feels_like": 40.0, "local_hour": 17, "local_day": 9}
                ]
            }
        }
        """

    private static func forecast() throws -> TempestForecast {
        let response = try JSONDecoder().decode(
            BetterForecastResponseDTO.self,
            from: Data(fixture.utf8),
        )
        return TempestForecast(dto: response, units: .metric)
    }

    @Test("Hourly and daily both come from one response")
    func blocksMap() throws {
        let forecast = try Self.forecast()
        #expect(forecast.hours.count == 1)
        #expect(forecast.days.count == 3)
    }

    @Test("A day missing its low keeps the rest")
    func dayMissingLow() throws {
        let days = try Self.forecast().days
        let last = try #require(days.last)
        #expect(last.date == Date(timeIntervalSince1970: 1_791_663_600))
        #expect(last.highTemperature == 30)
        #expect(last.lowTemperature == nil)
        #expect(last.precipitationChance == nil)
        #expect(last.sunrise == nil)
    }

    @Test("Days have their high, low, rain chance, and sunrise/sunset")
    func dayMapping() throws {
        let days = try Self.forecast().days
        let clear = days[0]
        #expect(clear.dayNumber == 9)
        #expect(clear.monthNumber == 10)
        #expect(clear.icon == .clearDay)
        #expect(clear.conditions == "Clear")
        #expect(clear.highTemperature == 41)
        #expect(clear.lowTemperature == 24)
        #expect(clear.highTemperatureColor == "ff4c00")
        #expect(clear.lowTemperatureColor == "afde06")
        #expect(clear.precipitationChance == 0)
        #expect(clear.precipitationType == .rain)
        #expect(clear.precipitationIcon == .chanceRain)
        #expect(clear.sunrise == Date(timeIntervalSince1970: 1_791_513_600))
        #expect(clear.sunset == Date(timeIntervalSince1970: 1_791_556_200))

        #expect(days[1].precipitationChance == 55)
    }

    @Test("Hours map the icon, wind and local time")
    func hourMapping() throws {
        let hour = try #require(try Self.forecast().hours.first)
        #expect(hour.timestamp == Date(timeIntervalSince1970: 1_791_496_800))
        #expect(hour.icon == .clearDay)
        #expect(hour.conditions == "Clear")
        #expect(hour.airTemperature == 41)
        #expect(hour.stationPressure == 1006)
        #expect(hour.seaLevelPressure == 1010)
        #expect(hour.precipitationChance == 0.05)
        #expect(hour.precipitationIcon == .chanceRain)
        #expect(hour.windAverage == 3.2)
        #expect(hour.windAverageColor == "26fc59")
        #expect(hour.windGust == 4.5)
        #expect(hour.windGustColor == "ebf100")
        #expect(hour.windDirectionCardinal == .northNortheast)
        #expect(hour.windDirectionIcon == "wind-arrow-w")
        #expect(hour.uvIndex == 4.1)
        #expect(hour.feelsLike == 40)
        #expect(hour.localHour == 17)
        #expect(hour.localDay == 9)
        #expect(hour.precipitationType == nil)
    }

    @Test("The forecast keeps its location and time zone offset")
    func location() throws {
        let forecast = try Self.forecast()
        #expect(forecast.status?.code == 0)
        #expect(forecast.status?.message == "SUCCESS")
        #expect(forecast.latitude == 37.77493)
        #expect(forecast.longitude == -122.41942)
        #expect(forecast.timezoneOffsetMinutes == -480)
        #expect(forecast.sourceIDConditions == 5)
        #expect(forecast.buildCode == "abc123")
        #expect(forecast.refreshIntervalSeconds == 900)
        #expect(forecast.responseUnits?.temperature == .celsius)
        #expect(forecast.responseUnits?.brightness == "lux")
        #expect(forecast.responseUnits?.other == "metric")
        #expect(forecast.station?.id == 100_001)
        #expect(forecast.station?.heightAboveGround == 4.8)
        #expect(forecast.station?.elevation == 100.5)
        #expect(forecast.station?.isStationOnline == true)
        #expect(forecast.station?.state == 1)
    }

    @Test("Rows without a time are skipped")
    func unplaceableRows() throws {
        let fixture = """
            {"forecast": {
                "hourly": [{"air_temperature": 20}, {"time": 1791496800, "air_temperature": 21}],
                "daily": [{"air_temp_high": 30}, {"day_start_local": 1791577200, "air_temp_high": 28}]
            }}
            """

        let response = try JSONDecoder().decode(BetterForecastResponseDTO.self, from: Data(fixture.utf8))
        let forecast = TempestForecast(dto: response, units: .metric)
        #expect(forecast.hours.map(\.airTemperature) == [21])
        #expect(forecast.days.count == 1)
    }

    @Test("No forecast in the response means no hours or days")
    func emptyPayload() throws {
        let response = try JSONDecoder().decode(BetterForecastResponseDTO.self, from: Data("{}".utf8))
        let forecast = TempestForecast(dto: response, units: .metric)
        #expect(forecast.hours.isEmpty)
        #expect(forecast.days.isEmpty)
    }
}
