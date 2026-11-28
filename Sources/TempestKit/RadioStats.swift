//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The hub's radio counters, from the `radio_stats` array.
public struct RadioStats: Hashable, Sendable {

    /// The radio's protocol version.
    public let version: Int?
    /// How many times the radio has restarted.
    public let rebootCount: Int?
    /// I2C bus errors.
    public let i2cErrorCount: Int?
    /// The radio's state.
    public let state: RadioState?
    /// The network the radio is on.
    public let networkID: Int?

    /// Creates the radio counters from the values the API sends.
    ///
    /// - Parameters:
    ///   - version: The radio's protocol version.
    ///   - rebootCount: How many times the radio has restarted.
    ///   - i2cErrorCount: I2C bus errors.
    ///   - state: The radio's state.
    ///   - networkID: The network the radio is on.
    public init(
        version: Int?,
        rebootCount: Int?,
        i2cErrorCount: Int?,
        state: RadioState?,
        networkID: Int?,
    ) {
        self.version = version
        self.rebootCount = rebootCount
        self.i2cErrorCount = i2cErrorCount
        self.state = state
        self.networkID = networkID
    }
}
