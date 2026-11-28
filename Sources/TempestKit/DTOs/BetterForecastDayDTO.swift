//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One day from `better_forecast`. Temperatures are metric because we ask
/// for metric.
struct BetterForecastDayDTO: Decodable, Sendable {

    let dayStartLocal: Int?
    let dayNumber: Int?
    let monthNumber: Int?
    let conditions: String?
    let icon: String?
    let highTemperature: Double?
    let lowTemperature: Double?
    let highTemperatureColor: String?
    let lowTemperatureColor: String?
    let precipitationProbability: Double?
    let precipitationType: String?
    let precipitationIcon: String?
    let sunrise: Int?
    let sunset: Int?

    private enum CodingKeys: String, CodingKey {
        case dayStartLocal = "day_start_local"
        case dayNumber = "day_num"
        case monthNumber = "month_num"
        case conditions
        case icon
        case highTemperature = "air_temp_high"
        case lowTemperature = "air_temp_low"
        case highTemperatureColor = "air_temp_high_color"
        case lowTemperatureColor = "air_temp_low_color"
        case precipitationProbability = "precip_probability"
        case precipitationType = "precip_type"
        case precipitationIcon = "precip_icon"
        case sunrise
        case sunset
    }
}
