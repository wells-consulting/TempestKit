//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension WeatherStation {

    /// One sensor capability the station reports, with where it is installed.
    public struct Capability: Hashable, Sendable {

        /// The API's name for the capability, like `air_temperature_humidity`
        public let name: String
        /// The device the capability comes from.
        public let deviceID: Device.ID?
        /// Where the capability is installed.
        public let environment: Device.Environment?
        /// Meters above ground level
        public let heightAboveGround: Double?
        /// Whether the owner sees RainCheck final totals.
        public let showsPrecipitationFinal: Bool?

        /// Creates a capability from the values the API sends.
        ///
        /// - Parameters:
        ///   - name: The API's name for the capability.
        ///   - deviceID: The device the capability comes from.
        ///   - environment: Where the capability is installed.
        ///   - heightAboveGround: Meters above ground level.
        ///   - showsPrecipitationFinal: Whether the owner sees RainCheck
        ///     final totals.
        public init(
            name: String,
            deviceID: Device.ID? = nil,
            environment: Device.Environment? = nil,
            heightAboveGround: Double? = nil,
            showsPrecipitationFinal: Bool? = nil
        ) {
            self.name = name
            self.deviceID = deviceID
            self.environment = environment
            self.heightAboveGround = heightAboveGround
            self.showsPrecipitationFinal = showsPrecipitationFinal
        }
    }
}
