//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension StationStatistics {

    /// One day's summary: average, high and low for most readings, plus rain,
    /// lightning and battery.
    ///
    /// Everything is optional. A station without a sensor sends nothing for
    /// it, and a partial day can be missing its highs and lows. Metric: °C,
    /// m/s, MB, lux, W/m², mm, km.
    public struct Day: Hashable, Sendable {

        /// The local day this row covers.
        public let date: DateComponents

        /// Average pressure, MB.
        public let pressure: Double?
        /// Highest pressure, MB.
        public let pressureHigh: Double?
        /// Lowest pressure, MB.
        public let pressureLow: Double?

        /// Average temperature, °C.
        public let temperature: Double?
        /// Highest temperature, °C.
        public let temperatureHigh: Double?
        /// Lowest temperature, °C.
        public let temperatureLow: Double?

        /// Average relative humidity, percent.
        public let relativeHumidity: Double?
        /// Highest relative humidity, percent.
        public let relativeHumidityHigh: Double?
        /// Lowest relative humidity, percent.
        public let relativeHumidityLow: Double?

        /// Average light, lux.
        public let illuminance: Double?
        /// Highest light, lux.
        public let illuminanceHigh: Double?
        /// Lowest light, lux.
        public let illuminanceLow: Double?

        /// Average UV index.
        public let uvIndex: Double?
        /// Highest UV index.
        public let uvIndexHigh: Double?
        /// Lowest UV index.
        public let uvIndexLow: Double?

        /// Average solar radiation, W/m².
        public let solarRadiation: Double?
        /// Highest solar radiation, W/m².
        public let solarRadiationHigh: Double?
        /// Lowest solar radiation, W/m².
        public let solarRadiationLow: Double?

        /// Average wind, m/s.
        public let windAverage: Double?
        /// Highest gust, m/s.
        public let windGust: Double?
        /// Lowest wind, m/s.
        public let windLull: Double?
        /// Average direction, degrees.
        public let windDirection: Double?
        /// Seconds between wind samples.
        public let windSampleInterval: Double?

        /// Strikes detected that day.
        public let lightningStrikeCount: Double?
        /// Average distance to those strikes, km.
        public let lightningStrikeAverageDistance: Double?

        /// How many observations went into this summary
        public let recordCount: Double?
        /// Average battery voltage, volts.
        public let batteryVoltage: Double?

        /// Rain for the day before RainCheck, mm.
        public let precipitation: Double?
        /// Rain for the day after RainCheck, mm.
        public let precipitationFinal: Double?
        /// Minutes of rain before RainCheck.
        public let precipitationMinutes: Double?
        /// Minutes of rain after RainCheck.
        public let precipitationMinutesFinal: Double?

        /// What fell that day
        public let precipitationType: PrecipitationType?
        /// Which RainCheck correction was applied to the rain total
        public let precipitationAnalysisType: PrecipitationAnalysis?

        /// Creates a day's summary from the values the API sends.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - date: The local day this row covers.
        ///   - pressure: Average pressure, MB.
        ///   - pressureHigh: Highest pressure, MB.
        ///   - pressureLow: Lowest pressure, MB.
        ///   - temperature: Average temperature, °C.
        ///   - temperatureHigh: Highest temperature, °C.
        ///   - temperatureLow: Lowest temperature, °C.
        ///   - relativeHumidity: Average relative humidity, percent.
        ///   - relativeHumidityHigh: Highest relative humidity, percent.
        ///   - relativeHumidityLow: Lowest relative humidity, percent.
        ///   - illuminance: Average light, lux.
        ///   - illuminanceHigh: Highest light, lux.
        ///   - illuminanceLow: Lowest light, lux.
        ///   - uvIndex: Average UV index.
        ///   - uvIndexHigh: Highest UV index.
        ///   - uvIndexLow: Lowest UV index.
        ///   - solarRadiation: Average solar radiation, W/m².
        ///   - solarRadiationHigh: Highest solar radiation, W/m².
        ///   - solarRadiationLow: Lowest solar radiation, W/m².
        ///   - windAverage: Average wind, m/s.
        ///   - windGust: Highest gust, m/s.
        ///   - windLull: Lowest wind, m/s.
        ///   - windDirection: Average direction, degrees.
        ///   - windSampleInterval: Seconds between wind samples.
        ///   - lightningStrikeCount: Strikes detected that day.
        ///   - lightningStrikeAverageDistance: Average distance to those
        ///     strikes, km.
        ///   - recordCount: How many observations went into the summary.
        ///   - batteryVoltage: Average battery voltage, volts.
        ///   - precipitation: Rain for the day before RainCheck, mm.
        ///   - precipitationFinal: Rain for the day after RainCheck, mm.
        ///   - precipitationMinutes: Minutes of rain before RainCheck.
        ///   - precipitationMinutesFinal: Minutes of rain after RainCheck.
        ///   - precipitationType: What fell that day.
        ///   - precipitationAnalysisType: Which RainCheck correction was
        ///     applied.
        public init(
            date: DateComponents,
            pressure: Double?,
            pressureHigh: Double?,
            pressureLow: Double?,
            temperature: Double?,
            temperatureHigh: Double?,
            temperatureLow: Double?,
            relativeHumidity: Double?,
            relativeHumidityHigh: Double?,
            relativeHumidityLow: Double?,
            illuminance: Double?,
            illuminanceHigh: Double?,
            illuminanceLow: Double?,
            uvIndex: Double?,
            uvIndexHigh: Double?,
            uvIndexLow: Double?,
            solarRadiation: Double?,
            solarRadiationHigh: Double?,
            solarRadiationLow: Double?,
            windAverage: Double?,
            windGust: Double?,
            windLull: Double?,
            windDirection: Double?,
            windSampleInterval: Double?,
            lightningStrikeCount: Double?,
            lightningStrikeAverageDistance: Double?,
            recordCount: Double?,
            batteryVoltage: Double?,
            precipitation: Double?,
            precipitationFinal: Double?,
            precipitationMinutes: Double?,
            precipitationMinutesFinal: Double?,
            precipitationType: PrecipitationType?,
            precipitationAnalysisType: PrecipitationAnalysis?
        ) {
            self.date = date
            self.pressure = pressure
            self.pressureHigh = pressureHigh
            self.pressureLow = pressureLow
            self.temperature = temperature
            self.temperatureHigh = temperatureHigh
            self.temperatureLow = temperatureLow
            self.relativeHumidity = relativeHumidity
            self.relativeHumidityHigh = relativeHumidityHigh
            self.relativeHumidityLow = relativeHumidityLow
            self.illuminance = illuminance
            self.illuminanceHigh = illuminanceHigh
            self.illuminanceLow = illuminanceLow
            self.uvIndex = uvIndex
            self.uvIndexHigh = uvIndexHigh
            self.uvIndexLow = uvIndexLow
            self.solarRadiation = solarRadiation
            self.solarRadiationHigh = solarRadiationHigh
            self.solarRadiationLow = solarRadiationLow
            self.windAverage = windAverage
            self.windGust = windGust
            self.windLull = windLull
            self.windDirection = windDirection
            self.windSampleInterval = windSampleInterval
            self.lightningStrikeCount = lightningStrikeCount
            self.lightningStrikeAverageDistance = lightningStrikeAverageDistance
            self.recordCount = recordCount
            self.batteryVoltage = batteryVoltage
            self.precipitation = precipitation
            self.precipitationFinal = precipitationFinal
            self.precipitationMinutes = precipitationMinutes
            self.precipitationMinutesFinal = precipitationMinutesFinal
            self.precipitationType = precipitationType
            self.precipitationAnalysisType = precipitationAnalysisType
        }
    }
}
