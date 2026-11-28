//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// What the station is reading right now, as sent along with the forecast.
    ///
    /// The values are in `TempestForecast.units`, which defaults to metric:
    /// °C, m/s, MB, mm.
    public struct CurrentConditions: Hashable, Sendable {

        /// When the conditions were recorded.
        public let timestamp: Date
        /// The API's text summary, like "Partly Cloudy".
        public let conditions: String?
        /// The icon for the conditions.
        public let icon: Icon?

        /// Air temperature, °C.
        public let airTemperature: Double?
        /// The barometer reading at the station, MB.
        public let stationPressure: Double?
        /// Station pressure adjusted to sea level, MB.
        public let seaLevelPressure: Double?
        /// Which way the pressure is moving.
        public let pressureTrend: PressureTrend?
        /// Relative humidity, percent.
        public let relativeHumidity: Double?
        /// Passed through as-is. The API has sent both 55 and 0.55 for the
        /// same thing, so check which one you got before showing it.
        public let precipitationChance: Double?

        /// Average wind, m/s.
        public let windAverage: Double?
        /// Gust speed, m/s.
        public let windGust: Double?
        /// Where the wind comes from, in degrees.
        public let windDirection: Double?
        /// `N`, `NNE`, etc.
        public let windDirectionCardinal: CompassPoint?
        /// The API's icon name for the wind direction.
        public let windDirectionIcon: String?

        /// Solar radiation, W/m².
        public let solarRadiation: Double?
        /// The UV index.
        public let uvIndex: Double?
        /// Light, lux.
        public let illuminance: Double?

        /// Feels like temperature, °C.
        public let feelsLike: Double?
        /// Dew point, °C.
        public let dewPoint: Double?
        /// Wet bulb temperature, °C.
        public let wetBulb: Double?
        /// Wet bulb globe temperature, °C.
        public let wetBulbGlobe: Double?
        /// Delta T, °C.
        public let deltaT: Double?
        /// Air density, kg/m³.
        public let airDensity: Double?

        /// Strikes in the last hour.
        public let lightningStrikeCountLastHour: Int?
        /// Strikes in the last three hours.
        public let lightningStrikeCountLastThreeHours: Int?
        /// Distance to the last strike, km.
        public let lightningStrikeLastDistance: Double?
        /// The API's text describing the last strike's distance
        public let lightningStrikeLastDistanceMessage: String?
        /// When the last strike happened.
        public let lightningStrikeLastTime: Date?

        /// Rain since local midnight, mm
        public let precipitationToday: Double?
        /// Yesterday's rain, mm.
        public let precipitationYesterday: Double?
        /// Minutes of rain today.
        public let precipitationMinutesToday: Int?
        /// Minutes of rain yesterday.
        public let precipitationMinutesYesterday: Int?

        /// Whether today's rain total was adjusted by RainCheck
        public let precipitationTodayIsRainCheck: Bool?
        /// Whether yesterday's rain total was adjusted by RainCheck
        public let precipitationYesterdayIsRainCheck: Bool?
        /// Whether the station's own readings are part of the forecast
        public let includesStationData: Bool?

        /// Creates current conditions from the values the forecast carries.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - timestamp: When the conditions were recorded.
        ///   - conditions: The API's text summary.
        ///   - icon: The icon for the conditions.
        ///   - airTemperature: Air temperature, °C.
        ///   - stationPressure: The barometer reading at the station, MB.
        ///   - seaLevelPressure: Station pressure adjusted to sea level, MB.
        ///   - pressureTrend: Which way the pressure is moving.
        ///   - relativeHumidity: Relative humidity, percent.
        ///   - precipitationChance: Chance of precipitation. The API has sent
        ///     both 55 and 0.55.
        ///   - windAverage: Average wind, m/s.
        ///   - windGust: Gust speed, m/s.
        ///   - windDirection: Where the wind comes from, in degrees.
        ///   - windDirectionCardinal: The direction as `N`, `NNE`, etc.
        ///   - windDirectionIcon: The API's icon name for the wind direction.
        ///   - solarRadiation: Solar radiation, W/m².
        ///   - uvIndex: The UV index.
        ///   - illuminance: Light, lux.
        ///   - feelsLike: Feels like temperature, °C.
        ///   - dewPoint: Dew point, °C.
        ///   - wetBulb: Wet bulb temperature, °C.
        ///   - wetBulbGlobe: Wet bulb globe temperature, °C.
        ///   - deltaT: Delta T, °C.
        ///   - airDensity: Air density, kg/m³.
        ///   - lightningStrikeCountLastHour: Strikes in the last hour.
        ///   - lightningStrikeCountLastThreeHours: Strikes in the last three
        ///     hours.
        ///   - lightningStrikeLastDistance: Distance to the last strike, km.
        ///   - lightningStrikeLastDistanceMessage: The API's text for that
        ///     distance.
        ///   - lightningStrikeLastTime: When the last strike happened.
        ///   - precipitationToday: Rain since local midnight, mm.
        ///   - precipitationYesterday: Yesterday's rain, mm.
        ///   - precipitationMinutesToday: Minutes of rain today.
        ///   - precipitationMinutesYesterday: Minutes of rain yesterday.
        ///   - precipitationTodayIsRainCheck: Whether RainCheck adjusted
        ///     today's total.
        ///   - precipitationYesterdayIsRainCheck: Whether RainCheck adjusted
        ///     yesterday's total.
        ///   - includesStationData: Whether the station's own readings are
        ///     part of the forecast.
        public init(
            timestamp: Date,
            conditions: String?,
            icon: Icon?,
            airTemperature: Double?,
            stationPressure: Double?,
            seaLevelPressure: Double?,
            pressureTrend: PressureTrend?,
            relativeHumidity: Double?,
            precipitationChance: Double?,
            windAverage: Double?,
            windGust: Double?,
            windDirection: Double?,
            windDirectionCardinal: CompassPoint?,
            windDirectionIcon: String?,
            solarRadiation: Double?,
            uvIndex: Double?,
            illuminance: Double?,
            feelsLike: Double?,
            dewPoint: Double?,
            wetBulb: Double?,
            wetBulbGlobe: Double?,
            deltaT: Double?,
            airDensity: Double?,
            lightningStrikeCountLastHour: Int?,
            lightningStrikeCountLastThreeHours: Int?,
            lightningStrikeLastDistance: Double?,
            lightningStrikeLastDistanceMessage: String?,
            lightningStrikeLastTime: Date?,
            precipitationToday: Double?,
            precipitationYesterday: Double?,
            precipitationMinutesToday: Int?,
            precipitationMinutesYesterday: Int?,
            precipitationTodayIsRainCheck: Bool?,
            precipitationYesterdayIsRainCheck: Bool?,
            includesStationData: Bool?
        ) {
            self.timestamp = timestamp
            self.conditions = conditions
            self.icon = icon
            self.airTemperature = airTemperature
            self.stationPressure = stationPressure
            self.seaLevelPressure = seaLevelPressure
            self.pressureTrend = pressureTrend
            self.relativeHumidity = relativeHumidity
            self.precipitationChance = precipitationChance
            self.windAverage = windAverage
            self.windGust = windGust
            self.windDirection = windDirection
            self.windDirectionCardinal = windDirectionCardinal
            self.windDirectionIcon = windDirectionIcon
            self.solarRadiation = solarRadiation
            self.uvIndex = uvIndex
            self.illuminance = illuminance
            self.feelsLike = feelsLike
            self.dewPoint = dewPoint
            self.wetBulb = wetBulb
            self.wetBulbGlobe = wetBulbGlobe
            self.deltaT = deltaT
            self.airDensity = airDensity
            self.lightningStrikeCountLastHour = lightningStrikeCountLastHour
            self.lightningStrikeCountLastThreeHours = lightningStrikeCountLastThreeHours
            self.lightningStrikeLastDistance = lightningStrikeLastDistance
            self.lightningStrikeLastDistanceMessage = lightningStrikeLastDistanceMessage
            self.lightningStrikeLastTime = lightningStrikeLastTime
            self.precipitationToday = precipitationToday
            self.precipitationYesterday = precipitationYesterday
            self.precipitationMinutesToday = precipitationMinutesToday
            self.precipitationMinutesYesterday = precipitationMinutesYesterday
            self.precipitationTodayIsRainCheck = precipitationTodayIsRainCheck
            self.precipitationYesterdayIsRainCheck = precipitationYesterdayIsRainCheck
            self.includesStationData = includesStationData
        }
    }
}
