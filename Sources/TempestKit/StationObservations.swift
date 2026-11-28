//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// An `/observations/stn` response: the rows plus the response's type, source,
/// units and status.
public struct StationObservations: Hashable, Sendable {

    /// The API's status object.
    public let status: ResponseStatus?
    /// The station the rows belong to.
    public let stationID: WeatherStation.ID
    /// The API's record type, usually `obs_station`
    public let type: String
    /// Where the response came from, like `db`
    public let source: String?
    /// The units the rows are in
    public let units: DisplayUnits?
    /// The `ob_fields` names, in row order
    public let fields: [String]?
    /// Oldest first
    public let rows: [StationObservation]

    /// Creates a response from the values it describes.
    ///
    /// The client builds these from the JSON, so most apps don't call this
    /// directly.
    ///
    /// - Parameters:
    ///   - status: The API's status object.
    ///   - stationID: The station the rows belong to.
    ///   - type: The API's record type.
    ///   - source: Where the response came from.
    ///   - units: The units the rows are in.
    ///   - fields: The `ob_fields` names, in row order.
    ///   - rows: The observations, oldest first.
    public init(
        status: ResponseStatus? = nil,
        stationID: WeatherStation.ID,
        type: String,
        source: String?,
        units: DisplayUnits?,
        fields: [String]? = nil,
        rows: [StationObservation]
    ) {
        self.status = status
        self.stationID = stationID
        self.type = type
        self.source = source
        self.units = units
        self.fields = fields
        self.rows = rows
    }
}
