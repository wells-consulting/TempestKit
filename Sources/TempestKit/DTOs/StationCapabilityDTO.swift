//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One `capabilities` row of a station response.
struct StationCapabilityDTO: Decodable, Sendable {

    let name: String?
    let deviceID: Int?
    let environment: String?
    let heightAboveGround: Double?
    let showsPrecipitationFinal: Bool?

    private enum CodingKeys: String, CodingKey {
        case name = "capability"
        case deviceID = "device_id"
        case environment
        case heightAboveGround = "agl"
        case showsPrecipitationFinal = "show_precip_final"
    }
}
