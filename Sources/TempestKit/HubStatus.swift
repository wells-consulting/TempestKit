//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The once-a-minute status the hub broadcasts on the local network.
public struct HubStatus: Hashable, Sendable {

    /// The hub's serial number, the `HB-…` one.
    public let serialNumber: String
    /// The firmware revision the hub reports.
    public let firmwareRevision: String?
    /// Seconds since the hub started
    public let uptime: TimeInterval?
    /// The hub's signal strength.
    public let rssi: Int?
    /// When the hub sent the status.
    public let timestamp: Date
    /// The reasons the hub reset.
    public let resetFlags: ResetFlags
    /// The API's reset flags exactly as it sent them
    public let resetFlagsRaw: String?
    /// The message sequence number.
    public let sequence: Int?
    /// The radio's counters.
    public let radioStats: RadioStats?

    /// Creates a hub status from the values the broadcast carries.
    ///
    /// - Parameters:
    ///   - serialNumber: The hub's serial number.
    ///   - firmwareRevision: The firmware revision the hub reports.
    ///   - uptime: Seconds since the hub started.
    ///   - rssi: The hub's signal strength.
    ///   - timestamp: When the hub sent the status.
    ///   - resetFlags: The reasons the hub reset.
    ///   - resetFlagsRaw: The API's reset flags exactly as it sent them.
    ///   - sequence: The message sequence number.
    ///   - radioStats: The radio's counters.
    public init(
        serialNumber: String,
        firmwareRevision: String?,
        uptime: TimeInterval?,
        rssi: Int?,
        timestamp: Date,
        resetFlags: ResetFlags,
        resetFlagsRaw: String?,
        sequence: Int?,
        radioStats: RadioStats?,
    ) {
        self.serialNumber = serialNumber
        self.firmwareRevision = firmwareRevision
        self.uptime = uptime
        self.rssi = rssi
        self.timestamp = timestamp
        self.resetFlags = resetFlags
        self.resetFlagsRaw = resetFlagsRaw
        self.sequence = sequence
        self.radioStats = radioStats
    }
}
