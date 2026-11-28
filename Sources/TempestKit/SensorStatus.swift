//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The sensor problems a device reports in its status broadcast.
///
/// The API sends a number with one bit per problem. Bits above
/// `0b100000000` are reserved, and they stay in `rawValue`.
public struct SensorStatus: OptionSet, Hashable, Sendable {

    /// The bits the API sent.
    public let rawValue: Int

    /// Creates a status from the bits the API sent.
    ///
    /// - Parameter rawValue: The bit field.
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let lightningFailed = SensorStatus(rawValue: 1 << 0)
    public static let lightningNoise = SensorStatus(rawValue: 1 << 1)
    /// Something nearby is interfering with the lightning sensor.
    public static let lightningDisturber = SensorStatus(rawValue: 1 << 2)
    public static let pressureFailed = SensorStatus(rawValue: 1 << 3)
    public static let temperatureFailed = SensorStatus(rawValue: 1 << 4)
    public static let humidityFailed = SensorStatus(rawValue: 1 << 5)
    public static let windFailed = SensorStatus(rawValue: 1 << 6)
    public static let precipitationFailed = SensorStatus(rawValue: 1 << 7)
    public static let lightUVFailed = SensorStatus(rawValue: 1 << 8)
    /// A power booster is connected.
    public static let powerBoosterDetected = SensorStatus(rawValue: 1 << 9)
    /// The power booster's battery is low.
    public static let powerBoosterDepleted = SensorStatus(rawValue: 1 << 15)
    /// The power booster has shore power.
    public static let powerBoosterShorePower = SensorStatus(rawValue: 1 << 16)
}
