//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `device_settings` part of a device response.
struct DeviceSettingsDTO: Decodable, Sendable {

    let showsPrecipitationFinal: Bool?

    private enum CodingKeys: String, CodingKey {
        case showsPrecipitationFinal = "show_precip_final"
    }
}
