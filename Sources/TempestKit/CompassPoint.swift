//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A 16-point compass direction.
///
/// The API sends strings like `NNE`. An unknown value still comes through as
/// its raw string, so a new point won't break a forecast.
public struct CompassPoint: RawRepresentable, Hashable, Sendable {

    /// The API's string, like `NNE`.
    public let rawValue: String

    /// Creates a point from the API's string.
    ///
    /// - Parameter rawValue: The API's value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let north = CompassPoint(rawValue: "N")
    public static let northNortheast = CompassPoint(rawValue: "NNE")
    public static let northeast = CompassPoint(rawValue: "NE")
    public static let eastNortheast = CompassPoint(rawValue: "ENE")
    public static let east = CompassPoint(rawValue: "E")
    public static let eastSoutheast = CompassPoint(rawValue: "ESE")
    public static let southeast = CompassPoint(rawValue: "SE")
    public static let southSoutheast = CompassPoint(rawValue: "SSE")
    public static let south = CompassPoint(rawValue: "S")
    public static let southSouthwest = CompassPoint(rawValue: "SSW")
    public static let southwest = CompassPoint(rawValue: "SW")
    public static let westSouthwest = CompassPoint(rawValue: "WSW")
    public static let west = CompassPoint(rawValue: "W")
    public static let westNorthwest = CompassPoint(rawValue: "WNW")
    public static let northwest = CompassPoint(rawValue: "NW")
    public static let northNorthwest = CompassPoint(rawValue: "NNW")
}
