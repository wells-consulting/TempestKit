//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `summary` part of an `/observations/device/{id}` response.
struct DeviceObservationSummaryDTO: Decodable, Sendable {

    let pressureTrend: String?
    let lightningStrikeCountLastHour: Int?
    let lightningStrikeCountLastThreeHours: Int?
    let precipitationLastHour: Double?
    let lightningStrikeLastDistance: Double?
    let lightningStrikeLastEpoch: Int?
    let precipitationYesterday: Double?
    let precipitationYesterdayFinal: Double?
    let precipitationAnalysisTypeYesterday: Int?
    let feelsLike: Double?
    let heatIndex: Double?
    let windChill: Double?
    let dewPoint: Double?
    let wetBulbTemperature: Double?
    let wetBulbGlobeTemperature: Double?
    let airDensity: Double?
    let deltaT: Double?
    let precipitationMinutesToday: Int?
    let precipitationMinutesYesterday: Int?

    private enum CodingKeys: String, CodingKey {
        case pressureTrend = "pressure_trend"
        case lightningStrikeCountLastHour = "strike_count_1h"
        case lightningStrikeCountLastThreeHours = "strike_count_3h"
        case precipitationLastHour = "precip_total_1h"
        case lightningStrikeLastDistance = "strike_last_dist"
        case lightningStrikeLastEpoch = "strike_last_epoch"
        case precipitationYesterday = "precip_accum_local_yesterday"
        case precipitationYesterdayFinal = "precip_accum_local_yesterday_final"
        case precipitationAnalysisTypeYesterday = "precip_analysis_type_yesterday"
        case feelsLike = "feels_like"
        case heatIndex = "heat_index"
        case windChill = "wind_chill"
        case dewPoint = "dew_point"
        case wetBulbTemperature = "wet_bulb_temperature"
        case wetBulbGlobeTemperature = "wet_bulb_globe_temperature"
        case airDensity = "air_density"
        case deltaT = "delta_t"
        case precipitationMinutesToday = "precip_minutes_local_day"
        case precipitationMinutesYesterday = "precip_minutes_local_yesterday"
    }
}
