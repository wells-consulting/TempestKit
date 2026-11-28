//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The once-a-minute status a sensor broadcasts on the local network.
public struct DeviceStatus: Hashable, Sendable {

    /// The device's serial number.
    public let serialNumber: String
    /// The hub that relayed the status, when it's known.
    public let hubSerialNumber: String?
    /// When the device sent the status.
    public let timestamp: Date
    /// Seconds since the device started
    public let uptime: TimeInterval?
    /// Volts
    public let voltage: Double?
    /// The firmware revision the device reports.
    public let firmwareRevision: String?
    /// The device's signal strength.
    public let rssi: Int?
    /// The device's signal strength as the hub saw it
    public let hubRSSI: Int?
    /// Which sensors are reporting problems.
    public let sensorStatus: SensorStatus
    /// Whether the device has debugging turned on
    public let debug: Bool?
    /// The firmware revision for the sonic wind sensor.
    public let sonicFirmware: String?

    /// Creates a device status from the values the broadcast carries.
    ///
    /// - Parameters:
    ///   - serialNumber: The device's serial number.
    ///   - hubSerialNumber: The hub that relayed the status.
    ///   - timestamp: When the device sent the status.
    ///   - uptime: Seconds since the device started.
    ///   - voltage: Battery voltage, volts.
    ///   - firmwareRevision: The firmware revision the device reports.
    ///   - rssi: The device's signal strength.
    ///   - hubRSSI: The signal strength as the hub saw it.
    ///   - sensorStatus: Which sensors are reporting problems.
    ///   - debug: Whether debugging is turned on.
    ///   - sonicFirmware: The firmware revision for the sonic wind sensor.
    public init(
        serialNumber: String,
        hubSerialNumber: String?,
        timestamp: Date,
        uptime: TimeInterval?,
        voltage: Double?,
        firmwareRevision: String?,
        rssi: Int?,
        hubRSSI: Int?,
        sensorStatus: SensorStatus,
        debug: Bool?,
        sonicFirmware: String?,
    ) {
        self.serialNumber = serialNumber
        self.hubSerialNumber = hubSerialNumber
        self.timestamp = timestamp
        self.uptime = uptime
        self.voltage = voltage
        self.firmwareRevision = firmwareRevision
        self.rssi = rssi
        self.hubRSSI = hubRSSI
        self.sensorStatus = sensorStatus
        self.debug = debug
        self.sonicFirmware = sonicFirmware
    }
}
