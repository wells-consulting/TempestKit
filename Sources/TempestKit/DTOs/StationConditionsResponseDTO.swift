//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// An `/observations/station/{id}` response, exactly as the API sends it.
/// Unlike `/observations/stn/{id}`, the fields have names instead of being
/// a plain array.
struct StationConditionsResponseDTO: Decodable, Sendable {

    let status: ResponseStatusDTO?
    let stationID: Int
    let stationName: String?
    let publicName: String?
    let isPublic: Bool?
    let timeZoneIdentifier: String?
    let latitude: Double?
    let longitude: Double?
    let elevation: Double?
    let units: DisplayUnitsDTO?
    let outdoorKeys: [String]
    /// Usually just one row. If there are more we use the newest.
    let observations: [StationConditionValuesDTO]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(ResponseStatusDTO.self, forKey: .status)
        stationID = try container.decode(Int.self, forKey: .stationID)
        stationName = try container.decodeIfPresent(String.self, forKey: .stationName)
        publicName = try container.decodeIfPresent(String.self, forKey: .publicName)
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic)
        timeZoneIdentifier = try container.decodeIfPresent(String.self, forKey: .timeZoneIdentifier)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        elevation = try container.decodeIfPresent(Double.self, forKey: .elevation)
        units = try container.decodeIfPresent(DisplayUnitsDTO.self, forKey: .units)
        outdoorKeys = try container.decodeIfPresent([String].self, forKey: .outdoorKeys) ?? []
        observations = try container.decodeIfPresent([StationConditionValuesDTO].self, forKey: .observations) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case stationID = "station_id"
        case stationName = "station_name"
        case publicName = "public_name"
        case isPublic = "is_public"
        case timeZoneIdentifier = "timezone"
        case latitude
        case longitude
        case elevation
        case units = "station_units"
        case outdoorKeys = "outdoor_keys"
        case observations = "obs"
    }
}

struct DisplayUnitsDTO: Decodable, Sendable {

    let temperature: String?
    let wind: String?
    let precipitation: String?
    let pressure: String?
    let distance: String?
    let direction: String?
    let brightness: String?
    let solarRadiation: String?
    let airDensity: String?
    let other: String?

    private enum CodingKeys: String, CodingKey {
        case temperature = "units_temp"
        case wind = "units_wind"
        case precipitation = "units_precip"
        case pressure = "units_pressure"
        case distance = "units_distance"
        case direction = "units_direction"
        case brightness = "units_brightness"
        case solarRadiation = "units_solar_radiation"
        case airDensity = "units_air_density"
        case other = "units_other"
    }
}

struct StationConditionValuesDTO: Decodable, Sendable {

    let timestamp: Int?
    let airTemperature: Double?
    let barometricPressure: Double?
    let stationPressure: Double?
    let seaLevelPressure: Double?
    let relativeHumidity: Double?
    let precipitation: Double?
    let precipitationLastHour: Double?
    let precipitationToday: Double?
    let precipitationTodayFinal: Double?
    let precipitationYesterday: Double?
    let precipitationYesterdayFinal: Double?
    let precipitationMinutesToday: Int?
    let precipitationMinutesYesterday: Int?
    let precipitationMinutesYesterdayFinal: Int?
    let precipitationAnalysisTypeYesterday: Int?
    let windLull: Double?
    let windAverage: Double?
    let windGust: Double?
    let windDirection: Double?
    let solarRadiation: Double?
    let uvIndex: Double?
    let illuminance: Double?
    let lightningStrikeLastEpoch: Int?
    let lightningStrikeLastDistance: Double?
    let lightningStrikeCount: Int?
    let lightningStrikeCountLastHour: Int?
    let lightningStrikeCountLastThreeHours: Int?
    let feelsLike: Double?
    let heatIndex: Double?
    let windChill: Double?
    let dewPoint: Double?
    let wetBulbTemperature: Double?
    let wetBulbGlobeTemperature: Double?
    let deltaT: Double?
    let airDensity: Double?
    let pressureTrend: String?

    let airTemperatureIndoor: Double?
    let stationPressureIndoor: Double?
    let seaLevelPressureIndoor: Double?
    let relativeHumidityIndoor: Double?
    let precipitationIndoor: Double?
    let precipitationLastHourIndoor: Double?
    let windLullIndoor: Double?
    let windAverageIndoor: Double?
    let windGustIndoor: Double?
    let windDirectionIndoor: Double?
    let illuminanceIndoor: Double?
    let uvIndexIndoor: Double?
    let solarRadiationIndoor: Double?
    let lightningStrikeLastEpochIndoor: Int?
    let lightningStrikeLastDistanceIndoor: Double?
    let lightningStrikeCountLastThreeHoursIndoor: Int?
    let feelsLikeIndoor: Double?
    let heatIndexIndoor: Double?
    let windChillIndoor: Double?
    let dewPointIndoor: Double?
    let wetBulbTemperatureIndoor: Double?
    let deltaTIndoor: Double?
    let airDensityIndoor: Double?

    var hasIndoorValues: Bool {
        airTemperatureIndoor != nil
            || stationPressureIndoor != nil
            || seaLevelPressureIndoor != nil
            || relativeHumidityIndoor != nil
            || precipitationIndoor != nil
            || precipitationLastHourIndoor != nil
            || windLullIndoor != nil
            || windAverageIndoor != nil
            || windGustIndoor != nil
            || windDirectionIndoor != nil
            || illuminanceIndoor != nil
            || uvIndexIndoor != nil
            || solarRadiationIndoor != nil
            || lightningStrikeLastEpochIndoor != nil
            || lightningStrikeLastDistanceIndoor != nil
            || lightningStrikeCountLastThreeHoursIndoor != nil
            || feelsLikeIndoor != nil
            || heatIndexIndoor != nil
            || windChillIndoor != nil
            || dewPointIndoor != nil
            || wetBulbTemperatureIndoor != nil
            || deltaTIndoor != nil
            || airDensityIndoor != nil
    }

    private enum CodingKeys: String, CodingKey {
        case timestamp
        case airTemperature = "air_temperature"
        case barometricPressure = "barometric_pressure"
        case stationPressure = "station_pressure"
        case seaLevelPressure = "sea_level_pressure"
        case relativeHumidity = "relative_humidity"
        case precipitation = "precip"
        case precipitationLastHour = "precip_accum_last_1hr"
        case precipitationToday = "precip_accum_local_day"
        case precipitationTodayFinal = "precip_accum_local_day_final"
        case precipitationYesterday = "precip_accum_local_yesterday"
        case precipitationYesterdayFinal = "precip_accum_local_yesterday_final"
        case precipitationMinutesToday = "precip_minutes_local_day"
        case precipitationMinutesYesterday = "precip_minutes_local_yesterday"
        case precipitationMinutesYesterdayFinal = "precip_minutes_local_yesterday_final"
        case precipitationAnalysisTypeYesterday = "precip_analysis_type_yesterday"
        case windLull = "wind_lull"
        case windAverage = "wind_avg"
        case windGust = "wind_gust"
        case windDirection = "wind_direction"
        case solarRadiation = "solar_radiation"
        case uvIndex = "uv"
        case illuminance = "brightness"
        case lightningStrikeLastEpoch = "lightning_strike_last_epoch"
        case lightningStrikeLastDistance = "lightning_strike_last_distance"
        case lightningStrikeCount = "lightning_strike_count"
        case lightningStrikeCountLastHour = "lightning_strike_count_last_1hr"
        case lightningStrikeCountLastThreeHours = "lightning_strike_count_last_3hr"
        case feelsLike = "feels_like"
        case heatIndex = "heat_index"
        case windChill = "wind_chill"
        case dewPoint = "dew_point"
        case wetBulbTemperature = "wet_bulb_temperature"
        case wetBulbGlobeTemperature = "wet_bulb_globe_temperature"
        case deltaT = "delta_t"
        case airDensity = "air_density"
        case pressureTrend = "pressure_trend"
        case airTemperatureIndoor = "air_temperature_indoor"
        case stationPressureIndoor = "barometric_pressure_indoor"
        case seaLevelPressureIndoor = "sea_level_pressure_indoor"
        case relativeHumidityIndoor = "relative_humidity_indoor"
        case precipitationIndoor = "precip_indoor"
        case precipitationLastHourIndoor = "precip_accum_last_1hr_indoor"
        case windLullIndoor = "wind_lull_indoor"
        case windAverageIndoor = "wind_avg_indoor"
        case windGustIndoor = "wind_gust_indoor"
        case windDirectionIndoor = "wind_direction_indoor"
        case illuminanceIndoor = "brightness_indoor"
        case uvIndexIndoor = "uv_indoor"
        case solarRadiationIndoor = "solar_radiation_indoor"
        case lightningStrikeLastEpochIndoor = "lightning_strike_last_epoch_indoor"
        case lightningStrikeLastDistanceIndoor = "lightning_strike_last_distance_indoor"
        case lightningStrikeCountLastThreeHoursIndoor = "lightning_strike_count_last_3hr_indoor"
        case feelsLikeIndoor = "feels_like_indoor"
        case heatIndexIndoor = "heat_index_indoor"
        case windChillIndoor = "wind_chill_indoor"
        case dewPointIndoor = "dew_point_indoor"
        case wetBulbTemperatureIndoor = "wet_bulb_temperature_indoor"
        case deltaTIndoor = "delta_t_indoor"
        case airDensityIndoor = "air_density_indoor"
    }
}
