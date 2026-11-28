//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension StationObservation {

    /// Maps a Tempest device reading to the station reading the rest of the
    /// package uses.
    ///
    /// A Tempest row has everything a station row has except sea level
    /// pressure, so that stays nil. A row from an Air or Sky device returns
    /// nil: a Sky has no temperature, and an Air is a device reading, not a
    /// station one.
    ///
    /// - Parameters:
    ///   - device: The device reading.
    ///   - stationID: The station the device belongs to.
    public init?(_ device: DeviceObservation, stationID: WeatherStation.ID) {
        guard device.deviceType == .tempest, let temperature = device.airTemperature else {
            return nil
        }
        self.init(
            stationID: stationID,
            timestamp: device.timestamp,
            reportInterval: device.reportInterval,
            windSampleInterval: device.windSampleInterval,
            windLull: device.windLull,
            windAverage: device.windAverage,
            windGust: device.windGust,
            windDirection: device.windDirection,
            stationPressure: device.stationPressure,
            seaLevelPressure: nil,
            airTemperature: temperature,
            relativeHumidity: device.relativeHumidity,
            illuminance: device.illuminance,
            uvIndex: device.uvIndex,
            solarRadiation: device.solarRadiation,
            precipitation: device.precipitation,
            localDayPrecipitation: device.localDayPrecipitation,
            precipitationType: device.precipitationType,
            lightningStrikeCount: device.lightningStrikeCount,
            lightningStrikeDistance: device.lightningStrikeDistance,
            nearcastPrecipitation: device.nearcastPrecipitation,
            nearcastLocalDayPrecipitation: device.nearcastLocalDayPrecipitation,
            precipitationAnalysis: device.precipitationAnalysis,
            batteryVoltage: device.batteryVoltage,
            firmwareRevision: device.firmwareRevision,
            hubSerialNumber: device.hubSerialNumber,
        )
    }
}
