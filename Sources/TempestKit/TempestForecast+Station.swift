//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

extension TempestForecast {

    /// The station the forecast came from, as the forecast response describes
    /// it.
    public struct Station: Hashable, Sendable {

        /// The station's ID.
        public let id: WeatherStation.ID?
        /// Meters above ground level
        public let heightAboveGround: Double?
        /// Meters above sea level
        public let elevation: Double?
        /// Whether the station is online.
        public let isStationOnline: Bool?
        /// The API's state code. The docs don't say what it means.
        public let state: Int?

        /// Creates the forecast's station details from the values it sends.
        ///
        /// - Parameters:
        ///   - id: The station's ID.
        ///   - heightAboveGround: Meters above ground level.
        ///   - elevation: Meters above sea level.
        ///   - isStationOnline: Whether the station is online.
        ///   - state: The API's state code.
        public init(
            id: WeatherStation.ID? = nil,
            heightAboveGround: Double? = nil,
            elevation: Double? = nil,
            isStationOnline: Bool? = nil,
            state: Int? = nil
        ) {
            self.id = id
            self.heightAboveGround = heightAboveGround
            self.elevation = elevation
            self.isStationOnline = isStationOnline
            self.state = state
        }
    }
}
