//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension WeatherStation {

    /// The kinds of hardware a station can have. Tempest is the current
    /// sensor. AIR and SKY are the older ones it replaced, but people who've
    /// had a station for a while may still have them.
    public enum DeviceType: String, Hashable, Sendable {
        case tempest
        case hub
        case air
        case sky
        case other

        /// The API uses short codes: `ST`, `HB`, `AR` and `SK`. It also sends
        /// the old long names in a few places, so we accept those too.
        /// Anything we don't know (new hardware, probably) becomes `.other` so
        /// one odd device doesn't break the whole station.
        init(code: String?) {
            switch code?.uppercased() {
            case "ST": self = .tempest
            case "HB": self = .hub
            case "AR", "AIR": self = .air
            case "SK", "SKY": self = .sky
            default: self = .other
            }
        }
    }
}
