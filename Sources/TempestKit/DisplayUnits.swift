//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The units the station owner picked in the Tempest app: `f` or `c`, `mph`
/// or `mps`, and so on.
///
/// These are NOT the units of the numbers we return. Those are metric unless
/// you ask the forecast for something else. Use these if you want to format
/// values the way the owner is used to seeing them.
public struct DisplayUnits: Hashable, Sendable {

    /// How the owner sees wind direction
    public enum Direction: String, CaseIterable, Sendable {
        /// A compass point, like `NNE`
        case cardinal
        /// Degrees, like 22
        case degrees
    }

    /// The owner's temperature unit.
    public let temperature: Units.Temperature?
    /// The owner's wind speed unit.
    public let wind: Units.Wind?
    /// The owner's rain unit.
    public let precipitation: Units.Precipitation?
    /// The owner's pressure unit.
    public let pressure: Units.Pressure?
    /// The owner's distance unit.
    public let distance: Units.Distance?
    /// How the owner sees wind direction.
    public let direction: Direction?
    /// The owner's light unit, as the API sent it
    public let brightness: String?
    /// The owner's solar radiation unit, as the API sent it
    public let solarRadiation: String?
    /// The owner's air density unit, as the API sent it
    public let airDensity: String?
    /// Usually `imperial` or `metric`
    public let other: String?

    /// Creates the units the owner picked in the Tempest app.
    ///
    /// - Parameters:
    ///   - temperature: Degrees Celsius or Fahrenheit.
    ///   - wind: Wind speed units.
    ///   - precipitation: Rain units.
    ///   - pressure: Pressure units.
    ///   - distance: Distance units.
    ///   - direction: Compass points or degrees.
    ///   - brightness: The owner's light unit.
    ///   - solarRadiation: The owner's solar radiation unit.
    ///   - airDensity: The owner's air density unit.
    ///   - other: Usually `imperial` or `metric`.
    public init(
        temperature: Units.Temperature?,
        wind: Units.Wind?,
        precipitation: Units.Precipitation?,
        pressure: Units.Pressure?,
        distance: Units.Distance?,
        direction: Direction?,
        brightness: String?,
        solarRadiation: String?,
        airDensity: String?,
        other: String?
    ) {
        self.temperature = temperature
        self.wind = wind
        self.precipitation = precipitation
        self.pressure = pressure
        self.distance = distance
        self.direction = direction
        self.brightness = brightness
        self.solarRadiation = solarRadiation
        self.airDensity = airDensity
        self.other = other
    }
}
