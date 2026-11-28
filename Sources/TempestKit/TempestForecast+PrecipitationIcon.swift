//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// The API's icon name for the chance of precipitation.
    ///
    /// An unknown value still comes through as its raw string.
    public struct PrecipitationIcon: RawRepresentable, Hashable, Sendable {

        /// The API's string.
        public let rawValue: String

        /// Creates an icon from the API's string.
        ///
        /// - Parameter rawValue: The API's value.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let chanceRain = PrecipitationIcon(rawValue: "chance-rain")
        public static let chanceSnow = PrecipitationIcon(rawValue: "chance-snow")
        public static let chanceSleet = PrecipitationIcon(rawValue: "chance-sleet")
    }
}
