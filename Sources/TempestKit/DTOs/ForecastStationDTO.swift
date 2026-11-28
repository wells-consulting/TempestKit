//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `station` part of a `better_forecast` response.
struct ForecastStationDTO: Decodable, Sendable {

    let id: Int?
    let heightAboveGround: Double?
    let elevation: Double?
    let isStationOnline: Bool?
    let state: Int?

    private enum CodingKeys: String, CodingKey {
        case id = "station_id"
        case heightAboveGround = "agl"
        case elevation
        case isStationOnline = "is_station_online"
        case state
    }
}
