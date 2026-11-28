//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// The precipitation the forecast expects.
    ///
    /// The API sends strings. An unknown value still comes through as its raw
    /// string, so a new kind of precipitation won't break the forecast.
    public struct PrecipitationType: RawRepresentable, Hashable, Sendable {

        /// The API's string.
        public let rawValue: String

        /// Creates a precipitation type from the API's string.
        ///
        /// - Parameter rawValue: The API's value.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let rain = PrecipitationType(rawValue: "rain")
        public static let snow = PrecipitationType(rawValue: "snow")
        public static let sleet = PrecipitationType(rawValue: "sleet")
        /// The swagger file lists this; the apidocs schema doesn't.
        public static let storm = PrecipitationType(rawValue: "storm")
    }
}
