//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct ConditionsMappingTests {

    private static let payload = """
        {
          "station_id": 100001,
          "station_name": "Test Station",
          "public_name": "San Francisco",
          "latitude": 37.77493,
          "longitude": -122.41942,
          "timezone": "America/Los_Angeles",
          "elevation": 150,
          "is_public": true,
          "status": {"status_code": 0},
          "station_units": {
            "units_temp": "f", "units_wind": "mph", "units_precip": "in",
            "units_pressure": "mb", "units_distance": "mi",
            "units_direction": "cardinal", "units_other": "imperial"
          },
          "outdoor_keys": ["air_temperature"],
          "obs": [{
            "timestamp": 1791491452,
            "air_temperature": 108.5,
            "barometric_pressure": 994.9,
            "station_pressure": 993.1,
            "sea_level_pressure": 1007.1,
            "relative_humidity": 16,
            "precip": 0,
            "precip_accum_last_1hr": 0,
            "precip_accum_local_day": 0.02,
            "precip_accum_local_day_final": 0.03,
            "precip_accum_local_yesterday": 0.0,
            "precip_accum_local_yesterday_final": 0.0,
            "precip_minutes_local_day": 3,
            "precip_minutes_local_yesterday": 0,
            "precip_minutes_local_yesterday_final": 0,
            "precip_analysis_type_yesterday": 1,
            "wind_avg": 0.1, "wind_direction": 122,
            "wind_gust": 1.1, "wind_lull": 0.0,
            "solar_radiation": 802, "uv": 8.88, "brightness": 96294,
            "lightning_strike_last_epoch": 1791490000,
            "lightning_strike_last_distance": 12,
            "lightning_strike_count": 0,
            "lightning_strike_count_last_1hr": 0,
            "lightning_strike_count_last_3hr": 2,
            "feels_like": 106, "heat_index": 105, "wind_chill": 108,
            "dew_point": 52, "wet_bulb_temperature": 65,
            "wet_bulb_globe_temperature": 88,
            "delta_t": 43.5, "air_density": 1.12,
            "pressure_trend": "steady"
          }]
        }
        """

    @Test("Conditions map all fields, plus the display units")
    func mapping() throws {
        let response = try JSONDecoder().decode(StationConditionsResponseDTO.self, from: Data(Self.payload.utf8))
        let conditions = try #require(StationConditions(dto: response))

        #expect(conditions.status?.code == 0)
        #expect(conditions.stationID == 100_001)
        #expect(conditions.stationName == "Test Station")
        #expect(conditions.publicName == "San Francisco")
        #expect(conditions.isPublic == true)
        #expect(conditions.timeZone?.identifier == "America/Los_Angeles")
        #expect(conditions.latitude == 37.77493)
        #expect(conditions.longitude == -122.41942)
        #expect(conditions.elevation == 150)
        #expect(conditions.outdoorKeys == ["air_temperature"])
        #expect(conditions.indoor == nil)
        #expect(conditions.displayUnits?.temperature == .fahrenheit)
        #expect(conditions.displayUnits?.wind == .milesPerHour)
        #expect(conditions.displayUnits?.direction == .cardinal)
        #expect(conditions.displayUnits?.other == "imperial")
        #expect(conditions.timestamp == Date(timeIntervalSince1970: 1_791_491_452))
        #expect(conditions.airTemperature == 108.5)
        #expect(conditions.stationPressure == 993.1)
        #expect(conditions.seaLevelPressure == 1007.1)
        #expect(conditions.windAverage == 0.1)
        #expect(conditions.windDirection == 122)
        #expect(conditions.precipitationToday == 0.02)
        #expect(conditions.precipitationTodayFinal == 0.03)
        #expect(conditions.precipitationMinutesToday == 3)
        #expect(conditions.precipitationAnalysisTypeYesterday == .rainCheckShown)
        #expect(conditions.lightningStrikeCountLastThreeHours == 2)
        #expect(conditions.lightningStrikeLastTime == Date(timeIntervalSince1970: 1_791_490_000))
        #expect(conditions.calculated?.deltaT == 43.5)
        #expect(conditions.calculated?.airDensity == 1.12)
        #expect(conditions.calculated?.pressureTrend == .steady)
    }

    @Test("The station pressure falls back to the barometer reading")
    func barometerFallback() throws {
        let payload = """
            {"station_id": 1, "obs": [{"timestamp": 1791491452, "barometric_pressure": 994.9}]}
            """
        let response = try JSONDecoder().decode(StationConditionsResponseDTO.self, from: Data(payload.utf8))
        let conditions = try #require(StationConditions(dto: response))

        #expect(conditions.stationPressure == 994.9)
        #expect(conditions.displayUnits == nil)
        #expect(conditions.outdoorKeys.isEmpty)
        #expect(conditions.indoor == nil)
        #expect(conditions.calculated?.feelsLike == nil)
    }

    @Test("Indoor readings come through when the station has them")
    func indoorMapping() throws {
        let payload = """
            {
              "station_id": 1,
              "obs": [{
                "timestamp": 1791491452,
                "air_temperature": 20,
                "air_temperature_indoor": 21.5,
                "barometric_pressure_indoor": 1002.5,
                "sea_level_pressure_indoor": 1010.0,
                "relative_humidity_indoor": 45,
                "precip_indoor": 0.1,
                "precip_accum_last_1hr_indoor": 0.2,
                "wind_lull_indoor": 0.5,
                "wind_avg_indoor": 1.2,
                "wind_gust_indoor": 2.0,
                "wind_direction_indoor": 90,
                "brightness_indoor": 500,
                "uv_indoor": 1,
                "solar_radiation_indoor": 20,
                "lightning_strike_last_epoch_indoor": 1791490000,
                "lightning_strike_last_distance_indoor": 8,
                "lightning_strike_count_last_3hr_indoor": 2,
                "feels_like_indoor": 21,
                "heat_index_indoor": 21,
                "wind_chill_indoor": 20.5,
                "dew_point_indoor": 10,
                "wet_bulb_temperature_indoor": 15,
                "delta_t_indoor": 5,
                "air_density_indoor": 1.2
              }]
            }
            """
        let response = try JSONDecoder().decode(StationConditionsResponseDTO.self, from: Data(payload.utf8))
        let conditions = try #require(StationConditions(dto: response))
        let indoor = try #require(conditions.indoor)

        #expect(indoor.airTemperature == 21.5)
        #expect(indoor.stationPressure == 1002.5)
        #expect(indoor.seaLevelPressure == 1010)
        #expect(indoor.relativeHumidity == 45)
        #expect(indoor.precipitation == 0.1)
        #expect(indoor.precipitationLastHour == 0.2)
        #expect(indoor.windLull == 0.5)
        #expect(indoor.windAverage == 1.2)
        #expect(indoor.windGust == 2)
        #expect(indoor.windDirection == 90)
        #expect(indoor.illuminance == 500)
        #expect(indoor.uvIndex == 1)
        #expect(indoor.solarRadiation == 20)
        #expect(indoor.lightningStrikeLastTime == Date(timeIntervalSince1970: 1_791_490_000))
        #expect(indoor.lightningStrikeLastDistance == 8)
        #expect(indoor.lightningStrikeCountLastThreeHours == 2)
        #expect(indoor.calculated?.feelsLike == 21)
        #expect(indoor.calculated?.windChill == 20.5)
        #expect(indoor.calculated?.dewPoint == 10)
        #expect(indoor.calculated?.wetBulb == 15)
        #expect(indoor.calculated?.deltaT == 5)
        #expect(indoor.calculated?.airDensity == 1.2)
    }

    @Test("No usable row means no conditions")
    func noObservation() throws {
        let payload = """
            {"station_id": 1, "obs": [{"air_temperature": 20}]}
            """
        let response = try JSONDecoder().decode(StationConditionsResponseDTO.self, from: Data(payload.utf8))

        #expect(StationConditions(dto: response) == nil)
    }
}
