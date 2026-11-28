//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One reading from a single device, as `/observations/device`, the
/// WebSocket and the UDP broadcasts send it.
///
/// Values are metric, exactly as the API sends them: °C, m/s, MB, lux, W/m²,
/// mm, km and volts. A device only reports what its hardware measures, so a
/// Sky row has no temperature and an Air row has no wind.
public struct DeviceObservation: Hashable, Sendable {

    /// The row layout. The REST response, the WebSocket message and the UDP
    /// broadcast all use one of these.
    public enum RowType: String, CaseIterable, Hashable, Sendable {
        case tempest = "obs_st"
        case air = "obs_air"
        case sky = "obs_sky"

        var deviceType: WeatherStation.DeviceType {
            switch self {
            case .tempest: .tempest
            case .air: .air
            case .sky: .sky
            }
        }
    }

    /// The kind of device the row came from.
    public let deviceType: WeatherStation.DeviceType
    /// When the device recorded the row.
    public let timestamp: Date
    /// Minutes between reports
    public let reportInterval: Double?
    /// Seconds between wind samples
    public let windSampleInterval: Double?

    /// Slowest 3 second wind sample, m/s
    public let windLull: Double?
    /// Average wind over the interval, m/s
    public let windAverage: Double?
    /// Fastest 3 second wind sample, m/s
    public let windGust: Double?
    /// Degrees. This is where the wind is coming *from*.
    public let windDirection: Double?

    /// MB (same as hPa)
    public let stationPressure: Double?
    /// °C
    public let airTemperature: Double?
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

    /// Rain during the interval after the NearCast correction, mm
    public let nearcastPrecipitation: Double?
    /// Rain since local midnight after the NearCast correction, mm
    public let nearcastLocalDayPrecipitation: Double?
    /// Which correction was applied to the rain total
    public let precipitationAnalysis: PrecipitationAnalysis?

    /// Volts
    public let batteryVoltage: Double?

    /// The firmware revision the broadcast carried, when it did
    public let firmwareRevision: String?

    /// The hub that relayed the broadcast, when the row came from UDP
    public let hubSerialNumber: String?

    /// Creates a device reading with the values the API returns.
    ///
    /// Most apps get one of these from the client or a live feed instead of
    /// building one by hand. A device only reports what its hardware measures,
    /// so the fields it doesn't have stay nil.
    ///
    /// - Parameters:
    ///   - deviceType: The kind of device.
    ///   - timestamp: When the device recorded the row.
    ///   - reportInterval: Minutes between reports.
    ///   - windSampleInterval: Seconds between wind samples.
    ///   - windLull: Slowest 3 second wind sample, m/s.
    ///   - windAverage: Average wind over the interval, m/s.
    ///   - windGust: Fastest 3 second wind sample, m/s.
    ///   - windDirection: Where the wind comes from, in degrees.
    ///   - stationPressure: The barometer reading, MB.
    ///   - airTemperature: Air temperature, °C.
    ///   - relativeHumidity: Relative humidity, percent.
    ///   - illuminance: Light, lux.
    ///   - uvIndex: The UV index.
    ///   - solarRadiation: Solar radiation, W/m².
    ///   - precipitation: Rain during the interval, mm.
    ///   - localDayPrecipitation: Rain since local midnight, mm.
    ///   - precipitationType: What fell during the interval.
    ///   - lightningStrikeCount: Strikes detected during the interval.
    ///   - lightningStrikeDistance: Average distance to those strikes, km.
    ///   - nearcastPrecipitation: Rain during the interval after NearCast, mm.
    ///   - nearcastLocalDayPrecipitation: Rain since local midnight after
    ///     NearCast, mm.
    ///   - precipitationAnalysis: Which RainCheck correction was applied.
    ///   - batteryVoltage: Battery voltage, volts.
    ///   - firmwareRevision: The firmware revision, when the row had one.
    ///   - hubSerialNumber: The hub that relayed the broadcast, when the row
    ///     came from UDP.
    public init(
        deviceType: WeatherStation.DeviceType,
        timestamp: Date,
        reportInterval: Double?,
        windSampleInterval: Double?,
        windLull: Double?,
        windAverage: Double?,
        windGust: Double?,
        windDirection: Double?,
        stationPressure: Double?,
        airTemperature: Double?,
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
        self.deviceType = deviceType
        self.timestamp = timestamp
        self.reportInterval = reportInterval
        self.windSampleInterval = windSampleInterval
        self.windLull = windLull
        self.windAverage = windAverage
        self.windGust = windGust
        self.windDirection = windDirection
        self.stationPressure = stationPressure
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

    /// Maps one row from `/observations/device`, the WebSocket or UDP.
    ///
    /// A row without a timestamp returns nil. A row without a temperature
    /// still maps; a device can have a failed sensor. The Sky row can have 14
    /// values over UDP or 17 over REST and the WebSocket, and the Tempest row
    /// can have 18 or 22.
    ///
    /// - Parameters:
    ///   - row: The numbers, in the order the API documents.
    ///   - type: Which layout the row uses.
    ///   - firmwareRevision: The firmware revision from the message, when it
    ///     has one.
    ///   - hubSerialNumber: The hub serial from the message, when it has one.
    public init?(
        row: [Double?],
        type: RowType,
        firmwareRevision: String? = nil,
        hubSerialNumber: String? = nil
    ) {
        switch type {
        case .tempest:
            self.init(
                tempestRow: row,
                firmwareRevision: firmwareRevision,
                hubSerialNumber: hubSerialNumber
            )
        case .air:
            self.init(
                airRow: row,
                firmwareRevision: firmwareRevision,
                hubSerialNumber: hubSerialNumber
            )
        case .sky:
            self.init(
                skyRow: row,
                firmwareRevision: firmwareRevision,
                hubSerialNumber: hubSerialNumber
            )
        }
    }
}

extension DeviceObservation {

    private init?(
        tempestRow row: [Double?],
        firmwareRevision: String?,
        hubSerialNumber: String?
    ) {
        func value(at index: Int) -> Double? {
            index < row.count ? row[index] : nil
        }
        guard let timestamp = value(at: 0) else { return nil }
        self.init(
            deviceType: .tempest,
            timestamp: Date(timeIntervalSince1970: timestamp),
            reportInterval: value(at: 17),
            windSampleInterval: value(at: 5),
            windLull: value(at: 1),
            windAverage: value(at: 2),
            windGust: value(at: 3),
            windDirection: value(at: 4),
            stationPressure: value(at: 6),
            airTemperature: value(at: 7),
            relativeHumidity: value(at: 8),
            illuminance: value(at: 9),
            uvIndex: value(at: 10),
            solarRadiation: value(at: 11),
            precipitation: value(at: 12),
            localDayPrecipitation: value(at: 18),
            precipitationType: value(at: 13)
                .flatMap(Int.init(exactly:))
                .map(PrecipitationType.init(code:)),
            lightningStrikeCount: value(at: 15).flatMap(Int.init(exactly:)),
            lightningStrikeDistance: value(at: 14),
            nearcastPrecipitation: value(at: 19),
            nearcastLocalDayPrecipitation: value(at: 20),
            precipitationAnalysis: value(at: 21)
                .flatMap(Int.init(exactly:))
                .map(PrecipitationAnalysis.init(code:)),
            batteryVoltage: value(at: 16),
            firmwareRevision: firmwareRevision,
            hubSerialNumber: hubSerialNumber,
        )
    }

    private init?(
        airRow row: [Double?],
        firmwareRevision: String?,
        hubSerialNumber: String?
    ) {
        func value(at index: Int) -> Double? {
            index < row.count ? row[index] : nil
        }
        guard let timestamp = value(at: 0) else { return nil }
        self.init(
            deviceType: .air,
            timestamp: Date(timeIntervalSince1970: timestamp),
            reportInterval: value(at: 7),
            windSampleInterval: nil,
            windLull: nil,
            windAverage: nil,
            windGust: nil,
            windDirection: nil,
            stationPressure: value(at: 1),
            airTemperature: value(at: 2),
            relativeHumidity: value(at: 3),
            illuminance: nil,
            uvIndex: nil,
            solarRadiation: nil,
            precipitation: nil,
            localDayPrecipitation: nil,
            precipitationType: nil,
            lightningStrikeCount: value(at: 4).flatMap(Int.init(exactly:)),
            lightningStrikeDistance: value(at: 5),
            nearcastPrecipitation: nil,
            nearcastLocalDayPrecipitation: nil,
            precipitationAnalysis: nil,
            batteryVoltage: value(at: 6),
            firmwareRevision: firmwareRevision,
            hubSerialNumber: hubSerialNumber,
        )
    }

    private init?(
        skyRow row: [Double?],
        firmwareRevision: String?,
        hubSerialNumber: String?
    ) {
        func value(at index: Int) -> Double? {
            index < row.count ? row[index] : nil
        }
        guard let timestamp = value(at: 0) else { return nil }
        self.init(
            deviceType: .sky,
            timestamp: Date(timeIntervalSince1970: timestamp),
            reportInterval: value(at: 9),
            windSampleInterval: value(at: 13),
            windLull: value(at: 4),
            windAverage: value(at: 5),
            windGust: value(at: 6),
            windDirection: value(at: 7),
            stationPressure: nil,
            airTemperature: nil,
            relativeHumidity: nil,
            illuminance: value(at: 1),
            uvIndex: value(at: 2),
            solarRadiation: value(at: 10),
            precipitation: value(at: 3),
            localDayPrecipitation: value(at: 11),
            precipitationType: value(at: 12)
                .flatMap(Int.init(exactly:))
                .map(PrecipitationType.init(code:)),
            lightningStrikeCount: nil,
            lightningStrikeDistance: nil,
            nearcastPrecipitation: value(at: 14),
            nearcastLocalDayPrecipitation: value(at: 15),
            precipitationAnalysis: value(at: 16)
                .flatMap(Int.init(exactly:))
                .map(PrecipitationAnalysis.init(code:)),
            batteryVoltage: value(at: 8),
            firmwareRevision: firmwareRevision,
            hubSerialNumber: hubSerialNumber,
        )
    }
}
