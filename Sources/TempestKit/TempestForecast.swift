//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A station's forecast: current conditions, the next several hours, and the
/// next several days.
///
/// The numbers are in `units`. `icon`, `conditions` and `precipitationType`
/// are the strings the API sends back. We don't turn them into an enum. How to
/// show the sky is up to your app.
public struct TempestForecast: Hashable, Sendable {

    /// What the station is reading now.
    public let currentConditions: CurrentConditions?

    /// The hourly forecast.
    public let hours: [Hour]
    /// The daily forecast.
    public let days: [Day]

    /// The API's name for the forecast location, usually a city
    public let locationName: String?

    /// The time zone for the forecast's local times
    public let timeZone: TimeZone?

    /// The forecast location's latitude
    public let latitude: Double?

    /// The forecast location's longitude
    public let longitude: Double?

    /// The forecast's offset from UTC, in minutes
    public let timezoneOffsetMinutes: Int?

    /// The units the forecast values are in
    public let units: Units

    /// The API's source ID for the current conditions
    public let sourceIDConditions: Int?

    /// The API's build code, as a string
    public let buildCode: String?

    /// How often the API rebuilds the forecast, in seconds
    public let refreshIntervalSeconds: Int?

    /// The units object the API sent back
    public let responseUnits: DisplayUnits?

    /// The station the forecast came from, as the forecast describes it
    public let station: Station?

    /// The API's status object
    public let status: ResponseStatus?

    /// - Parameters:
    ///   - currentConditions: What the station is reading now.
    ///   - hours: The hourly forecast.
    ///   - days: The daily forecast.
    ///   - locationName: The API's name for the forecast location.
    ///   - timeZone: The zone for the forecast's local times.
    ///   - latitude: The forecast location's latitude.
    ///   - longitude: The forecast location's longitude.
    ///   - timezoneOffsetMinutes: The forecast's offset from UTC, in minutes.
    ///   - units: The units the values are in.
    ///   - sourceIDConditions: The API's source ID for current conditions.
    ///   - buildCode: The API's build code.
    ///   - refreshIntervalSeconds: How often the forecast is rebuilt.
    ///   - responseUnits: The units object the API sent back.
    ///   - station: The station the forecast describes.
    ///   - status: The API's status object.
    public init(
        currentConditions: CurrentConditions?,
        hours: [Hour],
        days: [Day],
        locationName: String?,
        timeZone: TimeZone?,
        latitude: Double?,
        longitude: Double?,
        timezoneOffsetMinutes: Int?,
        units: Units,
        sourceIDConditions: Int? = nil,
        buildCode: String? = nil,
        refreshIntervalSeconds: Int? = nil,
        responseUnits: DisplayUnits? = nil,
        station: Station? = nil,
        status: ResponseStatus? = nil,
    ) {
        self.currentConditions = currentConditions
        self.hours = hours
        self.days = days
        self.locationName = locationName
        self.timeZone = timeZone
        self.latitude = latitude
        self.longitude = longitude
        self.timezoneOffsetMinutes = timezoneOffsetMinutes
        self.units = units
        self.sourceIDConditions = sourceIDConditions
        self.buildCode = buildCode
        self.refreshIntervalSeconds = refreshIntervalSeconds
        self.responseUnits = responseUnits
        self.station = station
        self.status = status
    }
}
