//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The station's latest reading, combined from all of its devices, plus
/// values the API calculates (feels like, dew point, etc.).
///
/// Metric, like everything else in this package. That's true even if the
/// owner has the Tempest app set to °F. See `displayUnits`.
public struct StationConditions: Hashable, Sendable {

    /// The API's status object.
    public let status: ResponseStatus?
    /// The station the conditions belong to.
    public let stationID: WeatherStation.ID
    /// The station's name.
    public let stationName: String?
    /// The name shown when the station is shared
    public let publicName: String?
    /// True if the station is shared on the public Tempest map
    public let isPublic: Bool?
    /// The station's time zone.
    public let timeZone: TimeZone?
    /// The station's latitude, when the API has one
    public let latitude: Double?
    /// The station's longitude, when the API has one
    public let longitude: Double?
    /// Meters above sea level
    public let elevation: Double?

    /// The units the owner picked in the Tempest app. The numbers here are
    /// still metric.
    public let displayUnits: DisplayUnits?

    /// When the station recorded the reading.
    public let timestamp: Date

    /// Air temperature, °C.
    public let airTemperature: Double?
    /// The barometer reading at the station, MB (same as hPa).
    public let stationPressure: Double?
    /// Station pressure adjusted to sea level, MB.
    public let seaLevelPressure: Double?
    /// Relative humidity, percent.
    public let relativeHumidity: Double?
    /// Slowest 3 second wind sample in the interval, m/s.
    public let windLull: Double?
    /// Average wind over the interval, m/s.
    public let windAverage: Double?
    /// Fastest 3 second wind sample in the interval, m/s.
    public let windGust: Double?
    /// Where the wind comes from, in degrees.
    public let windDirection: Double?
    /// Light, lux.
    public let illuminance: Double?
    /// The UV index.
    public let uvIndex: Double?
    /// Solar radiation, W/m².
    public let solarRadiation: Double?

    /// Rain during the reporting interval, mm.
    public let precipitation: Double?
    /// Rain in the last hour, mm.
    public let precipitationLastHour: Double?
    /// Rain since local midnight before RainCheck, mm.
    public let precipitationToday: Double?
    /// Rain since local midnight after RainCheck, mm.
    public let precipitationTodayFinal: Double?
    /// Yesterday's rain before RainCheck, mm.
    public let precipitationYesterday: Double?
    /// Yesterday's rain after RainCheck, mm.
    public let precipitationYesterdayFinal: Double?
    /// Minutes of rain today.
    public let precipitationMinutesToday: Int?
    /// Minutes of rain yesterday before RainCheck.
    public let precipitationMinutesYesterday: Int?
    /// Minutes of rain yesterday after RainCheck.
    public let precipitationMinutesYesterdayFinal: Int?
    /// Which RainCheck correction was applied to yesterday's total.
    public let precipitationAnalysisTypeYesterday: PrecipitationAnalysis?

    /// When the last strike happened.
    public let lightningStrikeLastTime: Date?
    /// Distance to the last strike, km.
    public let lightningStrikeLastDistance: Double?
    /// Strikes detected during the reporting interval.
    public let lightningStrikeCount: Int?
    /// Strikes in the last hour.
    public let lightningStrikeCountLastHour: Int?
    /// Strikes in the last three hours.
    public let lightningStrikeCountLastThreeHours: Int?

    /// The field names that came from an outdoor device.
    public let outdoorKeys: [String]

    /// Readings from an indoor device, if the station has one.
    public let indoor: Indoor?

    /// The values the API calculates from the readings.
    public let calculated: CalculatedValues?

    /// Creates a conditions value from the API's fields.
    ///
    /// The client builds these from the JSON, so most apps don't call this
    /// directly. The units are the same ones the properties describe.
    ///
    /// - Parameters:
    ///   - status: The API's status object.
    ///   - stationID: The station the conditions belong to.
    ///   - stationName: The station's name.
    ///   - publicName: The name shown when the station is shared.
    ///   - isPublic: True if the station is shared on the public map.
    ///   - timeZone: The station's time zone.
    ///   - latitude: The station's latitude, when the API has one.
    ///   - longitude: The station's longitude, when the API has one.
    ///   - elevation: Meters above sea level.
    ///   - displayUnits: The units the owner picked in the Tempest app.
    ///   - timestamp: When the station recorded the reading.
    ///   - airTemperature: Air temperature, °C.
    ///   - stationPressure: The barometer reading at the station, MB.
    ///   - seaLevelPressure: Station pressure adjusted to sea level, MB.
    ///   - relativeHumidity: Relative humidity, percent.
    ///   - windLull: Slowest 3 second wind sample, m/s.
    ///   - windAverage: Average wind over the interval, m/s.
    ///   - windGust: Fastest 3 second wind sample, m/s.
    ///   - windDirection: Where the wind comes from, in degrees.
    ///   - illuminance: Light, lux.
    ///   - uvIndex: The UV index.
    ///   - solarRadiation: Solar radiation, W/m².
    ///   - precipitation: Rain during the reporting interval, mm.
    ///   - precipitationLastHour: Rain in the last hour, mm.
    ///   - precipitationToday: Rain since local midnight before RainCheck, mm.
    ///   - precipitationTodayFinal: Rain since local midnight after RainCheck, mm.
    ///   - precipitationYesterday: Yesterday's rain before RainCheck, mm.
    ///   - precipitationYesterdayFinal: Yesterday's rain after RainCheck, mm.
    ///   - precipitationMinutesToday: Minutes of rain today.
    ///   - precipitationMinutesYesterday: Minutes of rain yesterday before
    ///     RainCheck.
    ///   - precipitationMinutesYesterdayFinal: Minutes of rain yesterday after
    ///     RainCheck.
    ///   - precipitationAnalysisTypeYesterday: Which RainCheck correction was
    ///     applied to yesterday's total.
    ///   - lightningStrikeLastTime: When the last strike happened.
    ///   - lightningStrikeLastDistance: Distance to the last strike, km.
    ///   - lightningStrikeCount: Strikes detected during the interval.
    ///   - lightningStrikeCountLastHour: Strikes in the last hour.
    ///   - lightningStrikeCountLastThreeHours: Strikes in the last three hours.
    ///   - outdoorKeys: The field names that came from an outdoor device.
    ///   - indoor: Readings from an indoor device, if the station has one.
    ///   - calculated: The values the API calculates from the readings.
    public init(
        status: ResponseStatus? = nil,
        stationID: WeatherStation.ID,
        stationName: String?,
        publicName: String?,
        isPublic: Bool?,
        timeZone: TimeZone?,
        latitude: Double?,
        longitude: Double?,
        elevation: Double?,
        displayUnits: DisplayUnits?,
        timestamp: Date,
        airTemperature: Double?,
        stationPressure: Double?,
        seaLevelPressure: Double?,
        relativeHumidity: Double?,
        windLull: Double?,
        windAverage: Double?,
        windGust: Double?,
        windDirection: Double?,
        illuminance: Double?,
        uvIndex: Double?,
        solarRadiation: Double?,
        precipitation: Double?,
        precipitationLastHour: Double?,
        precipitationToday: Double?,
        precipitationTodayFinal: Double?,
        precipitationYesterday: Double?,
        precipitationYesterdayFinal: Double?,
        precipitationMinutesToday: Int?,
        precipitationMinutesYesterday: Int?,
        precipitationMinutesYesterdayFinal: Int?,
        precipitationAnalysisTypeYesterday: PrecipitationAnalysis?,
        lightningStrikeLastTime: Date?,
        lightningStrikeLastDistance: Double?,
        lightningStrikeCount: Int?,
        lightningStrikeCountLastHour: Int?,
        lightningStrikeCountLastThreeHours: Int?,
        outdoorKeys: [String],
        indoor: Indoor?,
        calculated: CalculatedValues?
    ) {
        self.status = status
        self.stationID = stationID
        self.stationName = stationName
        self.publicName = publicName
        self.isPublic = isPublic
        self.timeZone = timeZone
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.displayUnits = displayUnits
        self.timestamp = timestamp
        self.airTemperature = airTemperature
        self.stationPressure = stationPressure
        self.seaLevelPressure = seaLevelPressure
        self.relativeHumidity = relativeHumidity
        self.windLull = windLull
        self.windAverage = windAverage
        self.windGust = windGust
        self.windDirection = windDirection
        self.illuminance = illuminance
        self.uvIndex = uvIndex
        self.solarRadiation = solarRadiation
        self.precipitation = precipitation
        self.precipitationLastHour = precipitationLastHour
        self.precipitationToday = precipitationToday
        self.precipitationTodayFinal = precipitationTodayFinal
        self.precipitationYesterday = precipitationYesterday
        self.precipitationYesterdayFinal = precipitationYesterdayFinal
        self.precipitationMinutesToday = precipitationMinutesToday
        self.precipitationMinutesYesterday = precipitationMinutesYesterday
        self.precipitationMinutesYesterdayFinal = precipitationMinutesYesterdayFinal
        self.precipitationAnalysisTypeYesterday = precipitationAnalysisTypeYesterday
        self.lightningStrikeLastTime = lightningStrikeLastTime
        self.lightningStrikeLastDistance = lightningStrikeLastDistance
        self.lightningStrikeCount = lightningStrikeCount
        self.lightningStrikeCountLastHour = lightningStrikeCountLastHour
        self.lightningStrikeCountLastThreeHours = lightningStrikeCountLastThreeHours
        self.outdoorKeys = outdoorKeys
        self.indoor = indoor
        self.calculated = calculated
    }
}

extension StationConditions {

    /// The same readings from an indoor device, if the station has one.
    ///
    /// The API only sends the fields the indoor device measures. Everything
    /// here is optional. Metric: °C, m/s, MB, lux, W/m², mm, km.
    public struct Indoor: Hashable, Sendable {

        /// Air temperature, °C.
        public let airTemperature: Double?
        /// The barometer reading, MB (same as hPa).
        public let stationPressure: Double?
        /// Station pressure adjusted to sea level, MB.
        public let seaLevelPressure: Double?
        /// Relative humidity, percent.
        public let relativeHumidity: Double?
        /// Rain during the reporting interval, mm.
        public let precipitation: Double?
        /// Rain in the last hour, mm.
        public let precipitationLastHour: Double?
        /// Slowest 3 second wind sample, m/s.
        public let windLull: Double?
        /// Average wind over the interval, m/s.
        public let windAverage: Double?
        /// Fastest 3 second wind sample, m/s.
        public let windGust: Double?
        /// Where the wind comes from, in degrees.
        public let windDirection: Double?
        /// Light, lux.
        public let illuminance: Double?
        /// The UV index.
        public let uvIndex: Double?
        /// Solar radiation, W/m².
        public let solarRadiation: Double?
        /// When the last strike happened.
        public let lightningStrikeLastTime: Date?
        /// Distance to the last strike, km.
        public let lightningStrikeLastDistance: Double?
        /// Strikes in the last three hours.
        public let lightningStrikeCountLastThreeHours: Int?
        /// The values the API calculates from these readings.
        public let calculated: CalculatedValues?

        /// Creates an indoor conditions value from the API's fields.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - airTemperature: Air temperature, °C.
        ///   - stationPressure: The barometer reading, MB.
        ///   - seaLevelPressure: Station pressure adjusted to sea level, MB.
        ///   - relativeHumidity: Relative humidity, percent.
        ///   - precipitation: Rain during the reporting interval, mm.
        ///   - precipitationLastHour: Rain in the last hour, mm.
        ///   - windLull: Slowest 3 second wind sample, m/s.
        ///   - windAverage: Average wind over the interval, m/s.
        ///   - windGust: Fastest 3 second wind sample, m/s.
        ///   - windDirection: Where the wind comes from, in degrees.
        ///   - illuminance: Light, lux.
        ///   - uvIndex: The UV index.
        ///   - solarRadiation: Solar radiation, W/m².
        ///   - lightningStrikeLastTime: When the last strike happened.
        ///   - lightningStrikeLastDistance: Distance to the last strike, km.
        ///   - lightningStrikeCountLastThreeHours: Strikes in the last three
        ///     hours.
        ///   - calculated: The values the API calculates from these readings.
        public init(
            airTemperature: Double?,
            stationPressure: Double?,
            seaLevelPressure: Double?,
            relativeHumidity: Double?,
            precipitation: Double?,
            precipitationLastHour: Double?,
            windLull: Double?,
            windAverage: Double?,
            windGust: Double?,
            windDirection: Double?,
            illuminance: Double?,
            uvIndex: Double?,
            solarRadiation: Double?,
            lightningStrikeLastTime: Date?,
            lightningStrikeLastDistance: Double?,
            lightningStrikeCountLastThreeHours: Int?,
            calculated: CalculatedValues?
        ) {
            self.airTemperature = airTemperature
            self.stationPressure = stationPressure
            self.seaLevelPressure = seaLevelPressure
            self.relativeHumidity = relativeHumidity
            self.precipitation = precipitation
            self.precipitationLastHour = precipitationLastHour
            self.windLull = windLull
            self.windAverage = windAverage
            self.windGust = windGust
            self.windDirection = windDirection
            self.illuminance = illuminance
            self.uvIndex = uvIndex
            self.solarRadiation = solarRadiation
            self.lightningStrikeLastTime = lightningStrikeLastTime
            self.lightningStrikeLastDistance = lightningStrikeLastDistance
            self.lightningStrikeCountLastThreeHours = lightningStrikeCountLastThreeHours
            self.calculated = calculated
        }
    }
}
