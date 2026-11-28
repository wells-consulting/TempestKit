//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Everything the station measured at one point in time.
///
/// Values are metric, exactly as the API sends them: °C, m/s, MB, lux, W/m²,
/// mm, km. We don't convert anything or calculate anything (feels like, sky
/// conditions, etc.). That's up to your app.
public struct StationObservation: Hashable, Sendable {

    /// The station that recorded the row.
    public let stationID: WeatherStation.ID

    /// When the station recorded it.
    public let timestamp: Date

    /// Minutes between reports. Always 1 for a Tempest.
    public let reportInterval: Double?

    /// Seconds between wind samples
    public let windSampleInterval: Double?

    /// Slowest 3 second wind sample in the interval, m/s
    public let windLull: Double?

    /// Average wind over the interval, m/s
    public let windAverage: Double?

    /// Fastest 3 second wind sample in the interval, m/s
    public let windGust: Double?

    /// Degrees. This is where the wind is coming *from*.
    public let windDirection: Double?

    /// The barometer reading at the station, MB (same as hPa)
    public let stationPressure: Double?

    /// Station pressure adjusted to sea level, MB
    public let seaLevelPressure: Double?

    /// °C. This is the one reading that isn't optional. If a row doesn't
    /// have a temperature we throw the whole row away.
    public let airTemperature: Double

    /// Percent
    public let relativeHumidity: Double?

    /// Lux
    public let illuminance: Double?

    /// The UV index.
    public let uvIndex: Double?

    /// W/m²
    public let solarRadiation: Double?

    /// Rain during the interval, mm
    public let precipitation: Double?

    /// Rain since local midnight, mm
    public let localDayPrecipitation: Double?

    /// What fell during the interval, or nil if the sensor didn't report.
    public let precipitationType: PrecipitationType?

    /// Strikes detected during the interval
    public let lightningStrikeCount: Int?

    /// Average distance of those strikes, km
    public let lightningStrikeDistance: Double?

    /// Rain during the interval after the API's NearCast correction, mm
    public let nearcastPrecipitation: Double?

    /// Rain since local midnight after the NearCast correction, mm
    public let nearcastLocalDayPrecipitation: Double?

    /// Which RainCheck correction was applied to the rain total
    public let precipitationAnalysis: PrecipitationAnalysis?

    /// Volts
    public let batteryVoltage: Double?

    /// The firmware revision the broadcast carried, when it did
    public let firmwareRevision: String?

    /// The hub that relayed the broadcast, when the row came from UDP
    public let hubSerialNumber: String?

    /// Creates an observation with the values the API returns.
    ///
    /// Most apps get one of these from the client or a live feed instead of
    /// building one by hand. The units are the same ones the properties
    /// describe.
    ///
    /// - Parameters:
    ///   - stationID: The station that recorded the row.
    ///   - timestamp: When the station recorded it.
    ///   - reportInterval: Minutes between reports.
    ///   - windSampleInterval: Seconds between wind samples.
    ///   - windLull: Slowest 3 second wind sample in the interval, m/s.
    ///   - windAverage: Average wind over the interval, m/s.
    ///   - windGust: Fastest 3 second wind sample in the interval, m/s.
    ///   - windDirection: Where the wind comes from, in degrees.
    ///   - stationPressure: The barometer reading at the station, MB.
    ///   - seaLevelPressure: Station pressure adjusted to sea level, MB.
    ///   - airTemperature: Air temperature, °C.
    ///   - relativeHumidity: Relative humidity, percent.
    ///   - illuminance: Light, lux.
    ///   - uvIndex: The UV index.
    ///   - solarRadiation: Solar radiation, W/m².
    ///   - precipitation: Rain during the interval, mm.
    ///   - localDayPrecipitation: Rain since local midnight, mm.
    ///   - precipitationType: What fell during the interval, or nil if the
    ///     sensor didn't report.
    ///   - lightningStrikeCount: Strikes detected during the interval.
    ///   - lightningStrikeDistance: Average distance of those strikes, km.
    ///   - nearcastPrecipitation: Rain during the interval after NearCast, mm.
    ///   - nearcastLocalDayPrecipitation: Rain since local midnight after
    ///     NearCast, mm.
    ///   - precipitationAnalysis: Which RainCheck correction was applied.
    ///   - batteryVoltage: Battery voltage, volts.
    ///   - firmwareRevision: The firmware revision, when the row had one.
    ///   - hubSerialNumber: The hub that relayed the broadcast, when the row
    ///     came from UDP.
    public init(
        stationID: WeatherStation.ID,
        timestamp: Date,
        reportInterval: Double?,
        windSampleInterval: Double?,
        windLull: Double?,
        windAverage: Double?,
        windGust: Double?,
        windDirection: Double?,
        stationPressure: Double?,
        seaLevelPressure: Double?,
        airTemperature: Double,
        relativeHumidity: Double?,
        illuminance: Double?,
        uvIndex: Double?,
        solarRadiation: Double?,
        precipitation: Double?,
        localDayPrecipitation: Double?,
        precipitationType: PrecipitationType?,
        lightningStrikeCount: Int?,
        lightningStrikeDistance: Double?,
        nearcastPrecipitation: Double?,
        nearcastLocalDayPrecipitation: Double?,
        precipitationAnalysis: PrecipitationAnalysis?,
        batteryVoltage: Double?,
        firmwareRevision: String? = nil,
        hubSerialNumber: String? = nil,
    ) {
        self.stationID = stationID
        self.timestamp = timestamp
        self.reportInterval = reportInterval
        self.windSampleInterval = windSampleInterval
        self.windLull = windLull
        self.windAverage = windAverage
        self.windGust = windGust
        self.windDirection = windDirection
        self.stationPressure = stationPressure
        self.seaLevelPressure = seaLevelPressure
        self.airTemperature = airTemperature
        self.relativeHumidity = relativeHumidity
        self.illuminance = illuminance
        self.uvIndex = uvIndex
        self.solarRadiation = solarRadiation
        self.precipitation = precipitation
        self.localDayPrecipitation = localDayPrecipitation
        self.precipitationType = precipitationType
        self.lightningStrikeCount = lightningStrikeCount
        self.lightningStrikeDistance = lightningStrikeDistance
        self.nearcastPrecipitation = nearcastPrecipitation
        self.nearcastLocalDayPrecipitation = nearcastLocalDayPrecipitation
        self.precipitationAnalysis = precipitationAnalysis
        self.batteryVoltage = batteryVoltage
        self.firmwareRevision = firmwareRevision
        self.hubSerialNumber = hubSerialNumber
    }
}
