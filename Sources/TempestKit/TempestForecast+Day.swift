//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// One day of the forecast. The temperatures are in `TempestForecast.units`.
    public struct Day: Hashable, Sendable {

        // The API also sends day_num and month_num. We skip them since
        // `date` already has that.

        /// The day the forecast is for.
        public let date: Date
        /// The day of the month, as the API sends it
        public let dayNumber: Int?
        /// The month number, as the API sends it
        public let monthNumber: Int?
        /// The icon for the conditions.
        public let icon: Icon?
        /// The API's text summary.
        public let conditions: String?
        /// High temperature, °C.
        public let highTemperature: Double?
        /// Low temperature, °C.
        public let lowTemperature: Double?
        /// The API's display color for the high, like `ff4c00`
        public let highTemperatureColor: String?
        /// The API's display color for the low, like `afde06`
        public let lowTemperatureColor: String?
        /// Passed through as-is. The API has sent both 55 and 0.55 for the
        /// same thing, so check which one you got before showing it.
        public let precipitationChance: Double?
        /// What kind of precipitation is expected.
        public let precipitationType: TempestForecast.PrecipitationType?
        /// The API's icon name for the precipitation type.
        public let precipitationIcon: PrecipitationIcon?
        /// When the sun rises.
        public let sunrise: Date?
        /// When the sun sets.
        public let sunset: Date?

        /// Creates a day of the forecast from the values the API sends.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - date: The day the forecast is for.
        ///   - dayNumber: The day of the month, as the API sends it.
        ///   - monthNumber: The month number, as the API sends it.
        ///   - icon: The icon for the conditions.
        ///   - conditions: The API's text summary.
        ///   - highTemperature: High temperature, °C.
        ///   - lowTemperature: Low temperature, °C.
        ///   - highTemperatureColor: The API's display color for the high.
        ///   - lowTemperatureColor: The API's display color for the low.
        ///   - precipitationChance: Chance of precipitation. The API has sent
        ///     both 55 and 0.55.
        ///   - precipitationType: What kind of precipitation is expected.
        ///   - precipitationIcon: The API's icon name for the precipitation.
        ///   - sunrise: When the sun rises.
        ///   - sunset: When the sun sets.
        public init(
            date: Date,
            dayNumber: Int? = nil,
            monthNumber: Int? = nil,
            icon: Icon?,
            conditions: String?,
            highTemperature: Double?,
            lowTemperature: Double?,
            highTemperatureColor: String? = nil,
            lowTemperatureColor: String? = nil,
            precipitationChance: Double?,
            precipitationType: TempestForecast.PrecipitationType?,
            precipitationIcon: PrecipitationIcon?,
            sunrise: Date?,
            sunset: Date?,
        ) {
            self.date = date
            self.dayNumber = dayNumber
            self.monthNumber = monthNumber
            self.icon = icon
            self.conditions = conditions
            self.highTemperature = highTemperature
            self.lowTemperature = lowTemperature
            self.highTemperatureColor = highTemperatureColor
            self.lowTemperatureColor = lowTemperatureColor
            self.precipitationChance = precipitationChance
            self.precipitationType = precipitationType
            self.precipitationIcon = precipitationIcon
            self.sunrise = sunrise
            self.sunset = sunset
        }
    }
}
