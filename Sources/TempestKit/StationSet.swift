//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A `/stations` response: the stations plus the API's status object.
public struct StationSet: Hashable, Sendable {

    /// The API's status object.
    public let status: ResponseStatus?
    /// The stations the token can see.
    public let stations: [WeatherStation]

    /// Creates a station list from the values it describes.
    ///
    /// - Parameters:
    ///   - status: The API's status object.
    ///   - stations: The stations the token can see.
    public init(status: ResponseStatus? = nil, stations: [WeatherStation]) {
        self.status = status
        self.stations = stations
    }
}
