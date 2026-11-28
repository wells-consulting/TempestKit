//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension WeatherStation {

    /// One piece of hardware on a station, like the hub or the sensor. The
    /// sensor does the measuring. The hub just passes the data along.
    public struct Device: Hashable, Sendable {

        /// Devices are identified by an integer.
        public typealias ID = Int

        /// Where a device is installed
        public enum Environment: String, Hashable, Sendable {
            case indoor
            case outdoor
            /// A value we don't know yet
            case other

            init(code: String?) {
                switch code?.lowercased() {
                case "indoor": self = .indoor
                case "outdoor": self = .outdoor
                default: self = .other
                }
            }
        }

        /// Where the device is and what it's called
        public struct Meta: Hashable, Sendable {

            /// Meters above ground level
            public let heightAboveGround: Double?
            /// The device's name, when the owner gave it one.
            public let name: String?
            /// Where the device is installed.
            public let environment: Environment?
            /// The Wi-Fi network the device is on.
            public let wifiNetworkName: String?

            /// Creates the device's placement and name.
            ///
            /// - Parameters:
            ///   - heightAboveGround: Meters above ground level.
            ///   - name: The device's name, when the owner gave it one.
            ///   - environment: Where the device is installed.
            ///   - wifiNetworkName: The Wi-Fi network the device is on.
            public init(
                heightAboveGround: Double?,
                name: String?,
                environment: Environment?,
                wifiNetworkName: String?,
            ) {
                self.heightAboveGround = heightAboveGround
                self.name = name
                self.environment = environment
                self.wifiNetworkName = wifiNetworkName
            }
        }

        /// The settings the owner picked for the device
        public struct Settings: Hashable, Sendable {

            /// Whether the owner sees RainCheck final totals
            public let showsPrecipitationFinal: Bool?

            /// Creates the owner's display settings.
            ///
            /// - Parameter showsPrecipitationFinal: Whether the owner sees
            ///   RainCheck final totals.
            public init(showsPrecipitationFinal: Bool?) {
                self.showsPrecipitationFinal = showsPrecipitationFinal
            }
        }

        /// The device's ID.
        public let id: ID
        /// The kind of device: hub, Tempest, Air or Sky.
        public let deviceType: DeviceType
        /// The serial number the hub broadcasts, when the API has one.
        public let serialNumber: String?
        /// The firmware revision the device reports.
        public let firmwareRevision: String?
        /// The hardware revision, as the API sent it
        public let hardwareRevision: String?
        /// Free-text notes from the owner
        public let notes: String?
        /// Where the device is and what it's called.
        public let meta: Meta?
        /// The settings the owner picked.
        public let settings: Settings?

        /// Creates a device from the values the API sends.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - id: The device's ID.
        ///   - deviceType: The kind of device.
        ///   - serialNumber: The serial number the hub broadcasts.
        ///   - firmwareRevision: The firmware revision the device reports.
        ///   - hardwareRevision: The hardware revision, as the API sent it.
        ///   - notes: Free-text notes from the owner.
        ///   - meta: Where the device is and what it's called.
        ///   - settings: The settings the owner picked.
        public init(
            id: ID,
            deviceType: DeviceType,
            serialNumber: String?,
            firmwareRevision: String?,
            hardwareRevision: String?,
            notes: String?,
            meta: Meta?,
            settings: Settings?,
        ) {
            self.id = id
            self.deviceType = deviceType
            self.serialNumber = serialNumber
            self.firmwareRevision = firmwareRevision
            self.hardwareRevision = hardwareRevision
            self.notes = notes
            self.meta = meta
            self.settings = settings
        }
    }
}
