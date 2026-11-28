//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A weather station on your account.
public struct WeatherStation: Hashable, Sendable {

    /// Stations are identified by an integer.
    public typealias ID = Int

    /// The station's ID.
    public let id: ID

    /// The API's location ID, when it differs from the station ID
    public let locationID: Int?

    /// The station's name.
    public let name: String

    /// The name shown when the station is shared
    public let publicName: String?

    /// The station's latitude, when the API has one
    public let latitude: Double?

    /// The station's longitude, when the API has one
    public let longitude: Double?

    /// The station's time zone.
    public let timeZone: TimeZone?

    /// The station's offset from UTC, in minutes
    public let timezoneOffsetMinutes: Int?

    /// Meters above sea level
    public let elevation: Double?

    /// Whether the station shares data with WeatherFlow
    public let sharesWithWeatherFlow: Bool?

    /// Whether the station shares data with Weather Underground
    public let sharesWithWeatherUnderground: Bool?

    /// Whether the hub is in local mode
    public let isLocalMode: Bool?

    /// The sensor capabilities the station reports
    public let capabilities: [Capability]

    /// The API's state code. The docs don't say what it means.
    public let state: Int?

    /// The station's devices, including the hub.
    public let devices: [Device]

    /// The sensor items configured on the station
    public let items: [Item]

    /// When the station was added to the account. There's no data before
    /// this, so don't bother asking for it.
    public let createdAt: Date?

    /// When the station was last changed
    public let lastModified: Date?

    /// The hub device, if the station has one
    public var hub: Device? {
        devices.first { $0.deviceType == .hub }
    }

    /// Creates a station from the values the API sends.
    ///
    /// The client builds these from the JSON, so most apps don't call this
    /// directly.
    ///
    /// - Parameters:
    ///   - id: The station's ID.
    ///   - locationID: The API's location ID, when it differs.
    ///   - name: The station's name.
    ///   - publicName: The name shown when the station is shared.
    ///   - latitude: The station's latitude, when the API has one.
    ///   - longitude: The station's longitude, when the API has one.
    ///   - timeZone: The station's time zone.
    ///   - timezoneOffsetMinutes: The station's offset from UTC, in minutes.
    ///   - elevation: Meters above sea level.
    ///   - sharesWithWeatherFlow: Whether the station shares data with
    ///     WeatherFlow.
    ///   - sharesWithWeatherUnderground: Whether the station shares data with
    ///     Weather Underground.
    ///   - isLocalMode: Whether the hub is in local mode.
    ///   - capabilities: The sensor capabilities the station reports.
    ///   - state: The API's state code.
    ///   - devices: The station's devices, including the hub.
    ///   - items: The sensor items configured on the station.
    ///   - createdAt: When the station was added to the account.
    ///   - lastModified: When the station was last changed.
    public init(
        id: ID,
        locationID: Int?,
        name: String,
        publicName: String?,
        latitude: Double?,
        longitude: Double?,
        timeZone: TimeZone?,
        timezoneOffsetMinutes: Int?,
        elevation: Double?,
        sharesWithWeatherFlow: Bool?,
        sharesWithWeatherUnderground: Bool?,
        isLocalMode: Bool?,
        capabilities: [Capability] = [],
        state: Int? = nil,
        devices: [Device],
        items: [Item],
        createdAt: Date?,
        lastModified: Date?,
    ) {
        self.id = id
        self.locationID = locationID
        self.name = name
        self.publicName = publicName
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
        self.timezoneOffsetMinutes = timezoneOffsetMinutes
        self.elevation = elevation
        self.sharesWithWeatherFlow = sharesWithWeatherFlow
        self.sharesWithWeatherUnderground = sharesWithWeatherUnderground
        self.isLocalMode = isLocalMode
        self.capabilities = capabilities
        self.state = state
        self.devices = devices
        self.items = items
        self.createdAt = createdAt
        self.lastModified = lastModified
    }
}
