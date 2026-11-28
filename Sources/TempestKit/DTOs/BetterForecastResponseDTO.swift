//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A `better_forecast` response, exactly as the API sends it.
///
/// Almost everything is optional. The API docs say the format can vary, and
/// we'd rather skip a row than fail the whole decode.
struct BetterForecastResponseDTO: Decodable, Sendable {

    let status: ResponseStatusDTO?
    let forecast: BetterForecastBlockDTO?
    let currentConditions: ForecastCurrentConditionsDTO?
    let locationName: String?
    /// The time zone for the forecast's local times. We don't send one, so
    /// this is the only way to know.
    let timeZoneIdentifier: String?
    let latitude: Double?
    let longitude: Double?
    let timezoneOffsetMinutes: Int?
    let sourceIDConditions: Int?
    let buildCode: ForecastBuildCode?
    let refreshIntervalSeconds: Int?
    let units: DisplayUnitsDTO?
    let station: ForecastStationDTO?

    private enum CodingKeys: String, CodingKey {
        case status
        case forecast
        case currentConditions = "current_conditions"
        case locationName = "location_name"
        case timeZoneIdentifier = "timezone"
        case latitude
        case longitude
        case timezoneOffsetMinutes = "timezone_offset_minutes"
        case sourceIDConditions = "source_id_conditions"
        case buildCode = "build_code"
        case refreshIntervalSeconds = "refresh_interval_seconds"
        case units
        case station
    }
}

/// `build_code` can be a string or a number.
struct ForecastBuildCode: Decodable, Sendable {

    let value: String?

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            value = try container.decode(String.self)
        } catch {
            do {
                value = String(try container.decode(Int.self))
            } catch {
                value = nil
            }
        }
    }
}
