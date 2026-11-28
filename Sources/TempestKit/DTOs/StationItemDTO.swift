//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One `station_items` row.
struct StationItemDTO: Decodable, Sendable {

    let locationItemID: Int?
    let stationItemID: Int?
    let stationID: Int?
    let locationID: Int?
    let deviceID: Int?
    let name: String?
    let sort: Int?

    private enum CodingKeys: String, CodingKey {
        case locationItemID = "location_item_id"
        case stationItemID = "station_item_id"
        case stationID = "station_id"
        case locationID = "location_id"
        case deviceID = "device_id"
        case name = "item"
        case sort
    }
}
