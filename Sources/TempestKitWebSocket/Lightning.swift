//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A latitude and longitude box for the lightning feed.
public struct GeoBox: Hashable, Sendable {

    /// The box's south edge, in degrees.
    public let south: Double
    /// The box's west edge, in degrees.
    public let west: Double
    /// The box's north edge, in degrees.
    public let north: Double
    /// The box's east edge, in degrees.
    public let east: Double

    /// Creates a box from its edges.
    ///
    /// - Parameters:
    ///   - south: The south edge, in degrees.
    ///   - west: The west edge, in degrees.
    ///   - north: The north edge, in degrees.
    ///   - east: The east edge, in degrees.
    public init(south: Double, west: Double, north: Double, east: Double) {
        self.south = south
        self.west = west
        self.north = north
        self.east = east
    }
}

/// The kind of lightning strike the feed should return.
///
/// The API sends `cg` and `ic` back. `all` is only for the request.
public struct StrikeType: RawRepresentable, Hashable, Sendable {

    /// The API's string.
    public let rawValue: String

    /// Creates a strike type from the API's string.
    ///
    /// - Parameter rawValue: The API's value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let cloudToGround = StrikeType(rawValue: "cg")
    public static let cloudToCloud = StrikeType(rawValue: "ic")
    public static let all = StrikeType(rawValue: "all")
}

/// A request for the lightning feed.
public struct LightningRequest: Hashable, Sendable {

    /// The box to watch.
    public let bounds: GeoBox
    /// The strikes to return.
    public let strikeType: StrikeType

    /// Creates a request for the lightning feed.
    ///
    /// - Parameters:
    ///   - bounds: The box to watch.
    ///   - strikeType: The strikes to return. Defaults to all of them.
    public init(bounds: GeoBox, strikeType: StrikeType = .all) {
        self.bounds = bounds
        self.strikeType = strikeType
    }
}
