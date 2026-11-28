//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension WeatherStation {

    /// One sensor item configured on a station, like the air temperature and
    /// humidity from a particular device.
    public struct Item: Hashable, Sendable {

        /// The API's location item ID.
        public let locationItemID: Int?
        /// The API's station item ID.
        public let stationItemID: Int?
        /// The station's ID.
        public let stationID: Int?
        /// The station's location ID.
        public let locationID: Int?
        /// The device the item comes from.
        public let deviceID: Device.ID?
        /// The API's name for the item, like `air_temperature_humidity`
        public let name: String
        /// The order the API lists the item in.
        public let sort: Int?

        /// Creates a station item from the values the API sends.
        ///
        /// - Parameters:
        ///   - locationItemID: The API's location item ID.
        ///   - stationItemID: The API's station item ID.
        ///   - stationID: The station's ID.
        ///   - locationID: The station's location ID.
        ///   - deviceID: The device the item comes from.
        ///   - name: The API's name for the item.
        ///   - sort: The order the API lists the item in.
        public init(
            locationItemID: Int?,
            stationItemID: Int?,
            stationID: Int?,
            locationID: Int?,
            deviceID: Device.ID?,
            name: String,
            sort: Int?,
        ) {
            self.locationItemID = locationItemID
            self.stationItemID = stationItemID
            self.stationID = stationID
            self.locationID = locationID
            self.deviceID = deviceID
            self.name = name
            self.sort = sort
        }
    }
}
