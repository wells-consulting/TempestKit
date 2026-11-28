//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The units to ask the API for, and the units the station owner picked.
///
/// The forecast takes a `Units` value. The owner's `DisplayUnits` uses the
/// same enums, so one word means one thing in both places.
public struct Units: Hashable, Sendable {

    /// Temperature units
    public enum Temperature: String, CaseIterable, Sendable {
        case celsius = "c"
        case fahrenheit = "f"
    }

    /// Wind speed units
    public enum Wind: String, CaseIterable, Sendable {
        case metersPerSecond = "mps"
        case milesPerHour = "mph"
        case kilometersPerHour = "kph"
        case knots = "kts"
        /// The Beaufort scale
        case beaufort = "bft"
        /// Feet per minute. The API calls it `lfm`.
        case feetPerMinute = "lfm"
    }

    /// Pressure units
    public enum Pressure: String, CaseIterable, Sendable {
        case millibars = "mb"
        case inchesOfMercury = "inhg"
        case millimetersOfMercury = "mmhg"
        /// The same as millibars, but the API lists both.
        case hectopascals = "hpa"
    }

    /// Rain units
    public enum Precipitation: String, CaseIterable, Sendable {
        case millimeters = "mm"
        case centimeters = "cm"
        case inches = "in"
    }

    /// Distance units, for lightning and visibility
    public enum Distance: String, CaseIterable, Sendable {
        case kilometers = "km"
        case miles = "mi"
    }

    /// The temperature units.
    public let temperature: Temperature
    /// The wind speed units.
    public let wind: Wind
    /// The pressure units.
    public let pressure: Pressure
    /// The rain units.
    public let precipitation: Precipitation
    /// The distance units, for lightning and visibility.
    public let distance: Distance

    /// Every value defaults to the API's own default, so `Units()` is metric.
    ///
    /// - Parameters:
    ///   - temperature: Degrees Celsius or Fahrenheit.
    ///   - wind: Wind speed units.
    ///   - pressure: Pressure units.
    ///   - precipitation: Rain units.
    ///   - distance: Distance units.
    public init(
        temperature: Temperature = .celsius,
        wind: Wind = .metersPerSecond,
        pressure: Pressure = .millibars,
        precipitation: Precipitation = .millimeters,
        distance: Distance = .kilometers
    ) {
        self.temperature = temperature
        self.wind = wind
        self.pressure = pressure
        self.precipitation = precipitation
        self.distance = distance
    }

    /// The API's default units: °C, m/s, MB, mm and km.
    public static let metric = Units()

    /// The common US set: °F, mph, inHg, inches and miles.
    public static let imperial = Units(
        temperature: .fahrenheit,
        wind: .milesPerHour,
        pressure: .inchesOfMercury,
        precipitation: .inches,
        distance: .miles
    )

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "units_temp", value: temperature.rawValue),
            URLQueryItem(name: "units_wind", value: wind.rawValue),
            URLQueryItem(name: "units_pressure", value: pressure.rawValue),
            URLQueryItem(name: "units_precip", value: precipitation.rawValue),
            URLQueryItem(name: "units_distance", value: distance.rawValue),
        ]
    }
}
