//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One hour from `better_forecast`. Metric (°C, m/s, MB, mm) because we ask
/// for metric.
struct BetterForecastHourDTO: Decodable, Sendable {

    let time: Int?
    let conditions: String?
    let icon: String?
    let airTemperature: Double?
    let relativeHumidity: Double?
    let stationPressure: Double?
    let seaLevelPressure: Double?
    let precipitation: Double?
    let precipitationProbability: Double?
    let precipitationType: String?
    let precipitationIcon: String?
    let windAverage: Double?
    let windAverageColor: String?
    let windGust: Double?
    let windGustColor: String?
    let windDirection: Double?
    let windDirectionCardinal: String?
    let windDirectionIcon: String?
    let uvIndex: Double?
    let feelsLike: Double?
    let localHour: Int?
    let localDay: Int?

    private enum CodingKeys: String, CodingKey {
        case time
        case conditions
        case icon
        case airTemperature = "air_temperature"
        case relativeHumidity = "relative_humidity"
        case stationPressure = "station_pressure"
        case seaLevelPressure = "sea_level_pressure"
        case precipitation = "precip"
        case precipitationProbability = "precip_probability"
        case precipitationType = "precip_type"
        case precipitationIcon = "precip_icon"
        case windAverage = "wind_avg"
        case windAverageColor = "wind_avg_color"
        case windGust = "wind_gust"
        case windGustColor = "wind_gust_color"
        case windDirection = "wind_direction"
        case windDirectionCardinal = "wind_direction_cardinal"
        case windDirectionIcon = "wind_direction_icon"
        case uvIndex = "uv"
        case feelsLike = "feels_like"
        case localHour = "local_hour"
        case localDay = "local_day"
    }
}
