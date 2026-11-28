//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A `/stations` response, exactly as the API sends it. Internal so tests can
/// decode saved JSON.
struct StationsResponseDTO: Decodable, Sendable {

    let status: ResponseStatusDTO?
    let stations: [StationDTO]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(ResponseStatusDTO.self, forKey: .status)
        // The docs use `stations`. The swagger file uses `locations`, so take
        // either one.
        stations =
            try container.decodeIfPresent([StationDTO].self, forKey: .stations)
            ?? container.decodeIfPresent([StationDTO].self, forKey: .locations)
            ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case stations
        case locations
    }
}
