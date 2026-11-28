//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// The API's icon name for the forecast.
    ///
    /// A live forecast used `possibly-*` for the chance icons. The apidocs
    /// schema says `possible-*` for some of them; we use what the API sends.
    /// An unknown value still comes through as its raw string, so a new icon
    /// won't break the forecast.
    public struct Icon: RawRepresentable, Hashable, Sendable {

        /// The API's icon name.
        public let rawValue: String

        /// Creates an icon from the API's name.
        ///
        /// - Parameter rawValue: The API's value.
        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let clearDay = Icon(rawValue: "clear-day")
        public static let clearNight = Icon(rawValue: "clear-night")
        public static let cloudy = Icon(rawValue: "cloudy")
        public static let foggy = Icon(rawValue: "foggy")
        public static let partlyCloudyDay = Icon(rawValue: "partly-cloudy-day")
        public static let partlyCloudyNight = Icon(rawValue: "partly-cloudy-night")
        public static let possiblyRainyDay = Icon(rawValue: "possibly-rainy-day")
        public static let possiblyRainyNight = Icon(rawValue: "possibly-rainy-night")
        public static let possiblySleetDay = Icon(rawValue: "possibly-sleet-day")
        public static let possiblySleetNight = Icon(rawValue: "possibly-sleet-night")
        public static let possiblySnowDay = Icon(rawValue: "possibly-snow-day")
        public static let possiblySnowNight = Icon(rawValue: "possibly-snow-night")
        public static let possiblyThunderstormDay = Icon(rawValue: "possibly-thunderstorm-day")
        public static let possiblyThunderstormNight = Icon(rawValue: "possibly-thunderstorm-night")
        public static let rainy = Icon(rawValue: "rainy")
        public static let sleet = Icon(rawValue: "sleet")
        public static let snow = Icon(rawValue: "snow")
        public static let thunderstorm = Icon(rawValue: "thunderstorm")
        public static let windy = Icon(rawValue: "windy")
    }
}
