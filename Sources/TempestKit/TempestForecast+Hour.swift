//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// One hour of the forecast. The values are in `TempestForecast.units`.
    public struct Hour: Hashable, Sendable {

        /// The start of the hour.
        public let timestamp: Date
        /// The icon for the conditions.
        public let icon: Icon?
        /// The API's text summary.
        public let conditions: String?
        /// Air temperature, °C.
        public let airTemperature: Double?
        /// Relative humidity, percent.
        public let relativeHumidity: Double?
        /// The barometer reading at the station, MB.
        public let stationPressure: Double?
        /// Station pressure adjusted to sea level, MB.
        public let seaLevelPressure: Double?
        /// Rain during the hour, mm.
        public let precipitation: Double?
        /// Passed through as-is. We've seen the API send both 55 and 0.55 for
        /// the same thing, so check which one you got before showing it.
        public let precipitationChance: Double?
        /// What kind of precipitation is expected.
        public let precipitationType: TempestForecast.PrecipitationType?
        /// The API's icon name for the precipitation type.
        public let precipitationIcon: PrecipitationIcon?
        /// Average wind, m/s.
        public let windAverage: Double?
        /// The API's display color for the average wind, like `26fc59`
        public let windAverageColor: String?
        /// Gust speed, m/s.
        public let windGust: Double?
        /// The API's display color for the gust, like `ebf100`
        public let windGustColor: String?
        /// Where the wind comes from, in degrees.
        public let windDirection: Double?
        /// The direction as `N`, `NNE`, etc.
        public let windDirectionCardinal: CompassPoint?
        /// The API's icon name for the wind direction.
        public let windDirectionIcon: String?
        /// The UV index.
        public let uvIndex: Double?
        /// Feels like temperature, °C.
        public let feelsLike: Double?
        /// The local hour, 0 through 23
        public let localHour: Int?
        /// The local day of the month
        public let localDay: Int?

        /// Creates an hour of the forecast from the values the API sends.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - timestamp: The start of the hour.
        ///   - icon: The icon for the conditions.
        ///   - conditions: The API's text summary.
        ///   - airTemperature: Air temperature, °C.
        ///   - relativeHumidity: Relative humidity, percent.
        ///   - stationPressure: The barometer reading at the station, MB.
        ///   - seaLevelPressure: Station pressure adjusted to sea level, MB.
        ///   - precipitation: Rain during the hour, mm.
        ///   - precipitationChance: Chance of precipitation. The API has sent
        ///     both 55 and 0.55.
        ///   - precipitationType: What kind of precipitation is expected.
        ///   - precipitationIcon: The API's icon name for the precipitation.
        ///   - windAverage: Average wind, m/s.
        ///   - windAverageColor: The API's display color for the wind.
        ///   - windGust: Gust speed, m/s.
        ///   - windGustColor: The API's display color for the gust.
        ///   - windDirection: Where the wind comes from, in degrees.
        ///   - windDirectionCardinal: The direction as `N`, `NNE`, etc.
        ///   - windDirectionIcon: The API's icon name for the direction.
        ///   - uvIndex: The UV index.
        ///   - feelsLike: Feels like temperature, °C.
        ///   - localHour: The local hour, 0 through 23.
        ///   - localDay: The local day of the month.
        public init(
            timestamp: Date,
            icon: Icon?,
            conditions: String?,
            airTemperature: Double?,
            relativeHumidity: Double?,
            stationPressure: Double?,
            seaLevelPressure: Double?,
            precipitation: Double?,
            precipitationChance: Double?,
            precipitationType: TempestForecast.PrecipitationType?,
            precipitationIcon: PrecipitationIcon?,
            windAverage: Double?,
            windAverageColor: String? = nil,
            windGust: Double?,
            windGustColor: String? = nil,
            windDirection: Double?,
            windDirectionCardinal: CompassPoint?,
            windDirectionIcon: String?,
            uvIndex: Double?,
            feelsLike: Double?,
            localHour: Int?,
            localDay: Int?,
        ) {
            self.timestamp = timestamp
            self.icon = icon
            self.conditions = conditions
            self.airTemperature = airTemperature
            self.relativeHumidity = relativeHumidity
            self.stationPressure = stationPressure
            self.seaLevelPressure = seaLevelPressure
            self.precipitation = precipitation
            self.precipitationChance = precipitationChance
            self.precipitationType = precipitationType
            self.precipitationIcon = precipitationIcon
            self.windAverage = windAverage
            self.windAverageColor = windAverageColor
            self.windGust = windGust
            self.windGustColor = windGustColor
            self.windDirection = windDirection
            self.windDirectionCardinal = windDirectionCardinal
            self.windDirectionIcon = windDirectionIcon
            self.uvIndex = uvIndex
            self.feelsLike = feelsLike
            self.localHour = localHour
            self.localDay = localDay
        }
    }
}
