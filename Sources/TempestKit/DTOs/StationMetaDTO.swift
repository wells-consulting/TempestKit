//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `station_meta` part of a station response.
struct StationMetaDTO: Decodable, Sendable {

    let elevation: Double?
    let shareWithWeatherFlow: Bool?
    let shareWithWeatherUnderground: Bool?

    private enum CodingKeys: String, CodingKey {
        case elevation
        case shareWithWeatherFlow = "share_with_wf"
        case shareWithWeatherUnderground = "share_with_wu"
    }
}
