//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// An `/observations/stn/{id}` response, exactly as the API sends it.
///
/// Each row is a plain array of numbers. A `null` means a sensor didn't
/// report, which is why it's `[Double?]`. (Timestamps fit in a Double just
/// fine, they're way under 2⁵³.) No `obs` at all means no rows.
///
/// `ob_fields` lists the field names in row order. We map by those names when
/// they're there, and fall back to the documented order when they're not.
struct StationObservationsResponseDTO: Decodable, Sendable {

    let status: ResponseStatusDTO?
    let stationID: Int?
    let type: String?
    let source: String?
    let units: DisplayUnitsDTO?
    let obs: [[Double?]]
    let obFields: [String]?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(ResponseStatusDTO.self, forKey: .status)
        stationID = try container.decodeIfPresent(Int.self, forKey: .stationID)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        units = try container.decodeIfPresent(DisplayUnitsDTO.self, forKey: .units)
        obs = try container.decodeIfPresent([[Double?]].self, forKey: .obs) ?? []
        obFields = try container.decodeIfPresent([String].self, forKey: .obFields)
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case stationID = "station_id"
        case type
        case source
        case units
        case obs
        case obFields = "ob_fields"
    }
}
