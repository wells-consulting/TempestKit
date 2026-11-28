//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Values the API calculates from the station's readings: feels like, dew
/// point, air density and so on.
///
/// We don't calculate any of these ourselves. They only come back from
/// `conditions(station:token:)`. Temperatures are °C.
public struct CalculatedValues: Hashable, Sendable {

    /// Feels like temperature, °C.
    public let feelsLike: Double?
    /// Heat index, °C.
    public let heatIndex: Double?
    /// Wind chill, °C.
    public let windChill: Double?
    /// Dew point, °C.
    public let dewPoint: Double?
    /// Wet bulb temperature, °C.
    public let wetBulb: Double?
    /// Wet bulb globe temperature, °C.
    public let wetBulbGlobe: Double?
    /// Air temperature minus wet bulb temperature. Farmers use it to decide
    /// when it's OK to spray.
    public let deltaT: Double?
    /// kg/m³
    public let airDensity: Double?
    /// Which way the pressure is moving.
    public let pressureTrend: PressureTrend?

    /// Creates the calculated values from the values the API sends.
    ///
    /// - Parameters:
    ///   - feelsLike: Feels like temperature, °C.
    ///   - heatIndex: Heat index, °C.
    ///   - windChill: Wind chill, °C.
    ///   - dewPoint: Dew point, °C.
    ///   - wetBulb: Wet bulb temperature, °C.
    ///   - wetBulbGlobe: Wet bulb globe temperature, °C.
    ///   - deltaT: Air temperature minus wet bulb temperature, °C.
    ///   - airDensity: Air density, kg/m³.
    ///   - pressureTrend: Which way the pressure is moving.
    public init(
        feelsLike: Double?,
        heatIndex: Double?,
        windChill: Double?,
        dewPoint: Double?,
        wetBulb: Double?,
        wetBulbGlobe: Double?,
        deltaT: Double?,
        airDensity: Double?,
        pressureTrend: PressureTrend?
    ) {
        self.feelsLike = feelsLike
        self.heatIndex = heatIndex
        self.windChill = windChill
        self.dewPoint = dewPoint
        self.wetBulb = wetBulb
        self.wetBulbGlobe = wetBulbGlobe
        self.deltaT = deltaT
        self.airDensity = airDensity
        self.pressureTrend = pressureTrend
    }
}
