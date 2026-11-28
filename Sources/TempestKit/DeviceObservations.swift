//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One `/observations/device` response: the rows, the row type and the
/// summary the API sends for the latest reading.
///
/// `type` is the API's raw row type, like `obs_st`. If it's a type we don't
/// know, `rows` is empty and `type` still says what the API sent.
public struct DeviceObservations: Hashable, Sendable {

    /// The API's status object.
    public let status: ResponseStatus?
    /// The device the rows belong to.
    public let deviceID: WeatherStation.Device.ID
    /// The API's raw row type, like `obs_st`.
    public let type: String
    /// Where the response came from, like `cache` or `db`
    public let source: String?
    /// The summary for the latest row, when the API sends one.
    public let summary: DeviceSummary?
    /// Oldest first
    public let rows: [DeviceObservation]

    /// Creates a response from the values it describes.
    ///
    /// - Parameters:
    ///   - status: The API's status object.
    ///   - deviceID: The device the rows belong to.
    ///   - type: The API's raw row type.
    ///   - source: Where the response came from.
    ///   - summary: The summary for the latest row.
    ///   - rows: The observations, oldest first.
    public init(
        status: ResponseStatus? = nil,
        deviceID: WeatherStation.Device.ID,
        type: String,
        source: String?,
        summary: DeviceSummary?,
        rows: [DeviceObservation],
    ) {
        self.status = status
        self.deviceID = deviceID
        self.type = type
        self.source = source
        self.summary = summary
        self.rows = rows
    }
}
