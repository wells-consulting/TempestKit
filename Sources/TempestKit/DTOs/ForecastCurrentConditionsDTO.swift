//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `current_conditions` part of a `better_forecast` response. Metric.
///
/// The API docs spell the lightning keys `lighting_...` (no "n"). The real
/// API spells them correctly, so that's what we use.
struct ForecastCurrentConditionsDTO: Decodable, Sendable {

    let time: Int?
    let conditions: String?
    let icon: String?
    let airTemperature: Double?
    let stationPressure: Double?
    let seaLevelPressure: Double?
    let pressureTrend: String?
    let relativeHumidity: Double?
    let precipitationProbability: Double?
    let windAverage: Double?
    let windGust: Double?
    let windDirection: Double?
    let windDirectionCardinal: String?
    let windDirectionIcon: String?
    let solarRadiation: Double?
    let uvIndex: Double?
    let illuminance: Double?
    let feelsLike: Double?
    let dewPoint: Double?
    let wetBulbTemperature: Double?
    let wetBulbGlobeTemperature: Double?
    let deltaT: Double?
    let airDensity: Double?
    let lightningStrikeCountLastHour: Int?
    let lightningStrikeCountLastThreeHours: Int?
    let lightningStrikeLastDistance: Double?
    let lightningStrikeLastDistanceMessage: String?
    let lightningStrikeLastEpoch: Int?
    let precipitationToday: Double?
    let precipitationYesterday: Double?
    let precipitationMinutesToday: Int?
    let precipitationMinutesYesterday: Int?
    let precipitationTodayIsRainCheck: Bool?
    let precipitationYesterdayIsRainCheck: Bool?
    let includesStationData: Bool?

    private enum CodingKeys: String, CodingKey {
        case time
        case conditions
        case icon
        case airTemperature = "air_temperature"
        case stationPressure = "station_pressure"
        case seaLevelPressure = "sea_level_pressure"
        case pressureTrend = "pressure_trend"
        case relativeHumidity = "relative_humidity"
        case precipitationProbability = "precip_probability"
        case windAverage = "wind_avg"
        case windGust = "wind_gust"
        case windDirection = "wind_direction"
        case windDirectionCardinal = "wind_direction_cardinal"
        case windDirectionIcon = "wind_direction_icon"
        case solarRadiation = "solar_radiation"
        case uvIndex = "uv"
        case illuminance = "brightness"
        case feelsLike = "feels_like"
        case dewPoint = "dew_point"
        case wetBulbTemperature = "wet_bulb_temperature"
        case wetBulbGlobeTemperature = "wet_bulb_globe_temperature"
        case deltaT = "delta_t"
        case airDensity = "air_density"
        case lightningStrikeCountLastHour = "lightning_strike_count_last_1hr"
        case lightningStrikeCountLastThreeHours = "lightning_strike_count_last_3hr"
        case lightningStrikeLastDistance = "lightning_strike_last_distance"
        case lightningStrikeLastDistanceMessage = "lightning_strike_last_distance_msg"
        case lightningStrikeLastEpoch = "lightning_strike_last_epoch"
        case precipitationToday = "precip_accum_local_day"
        case precipitationYesterday = "precip_accum_local_yesterday"
        case precipitationMinutesToday = "precip_minutes_local_day"
        case precipitationMinutesYesterday = "precip_minutes_local_yesterday"
        case precipitationTodayIsRainCheck = "is_precip_local_day_rain_check"
        case precipitationYesterdayIsRainCheck = "is_precip_local_yesterday_rain_check"
        case includesStationData = "includes_station_data"
    }
}
