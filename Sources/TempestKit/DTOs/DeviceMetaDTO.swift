//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `device_meta` part of a device response.
struct DeviceMetaDTO: Decodable, Sendable {

    let heightAboveGround: Double?
    let name: String?
    let environment: String?
    let wifiNetworkName: String?

    private enum CodingKeys: String, CodingKey {
        case heightAboveGround = "agl"
        case name
        case environment
        case wifiNetworkName = "wifi_network_name"
    }
}
