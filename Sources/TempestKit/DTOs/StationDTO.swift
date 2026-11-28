//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

struct StationDTO: Decodable, Sendable {

    let stationID: Int
    let locationID: Int?
    let name: String
    let publicName: String?
    let latitude: Double?
    let longitude: Double?
    let timeZoneIdentifier: String?
    let timezoneOffsetMinutes: Int?
    let stationMeta: StationMetaDTO?
    let createdEpoch: Double?
    let lastModifiedEpoch: Double?
    let capabilities: [StationCapabilityDTO]
    let state: Int?
    let devices: [StationDeviceDTO]
    let stationItems: [StationItemDTO]
    let isLocalMode: Bool?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stationID = try container.decode(Int.self, forKey: .stationID)
        locationID = try container.decodeIfPresent(Int.self, forKey: .locationID)
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Station \(stationID)"
        publicName = try container.decodeIfPresent(String.self, forKey: .publicName)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        timeZoneIdentifier = try container.decodeIfPresent(String.self, forKey: .timeZoneIdentifier)
        timezoneOffsetMinutes = try container.decodeIfPresent(Int.self, forKey: .timezoneOffsetMinutes)
        stationMeta = try container.decodeIfPresent(StationMetaDTO.self, forKey: .stationMeta)
        createdEpoch = try container.decodeIfPresent(Double.self, forKey: .createdEpoch)
        lastModifiedEpoch = try container.decodeIfPresent(Double.self, forKey: .lastModifiedEpoch)
        capabilities = try container.decodeIfPresent([StationCapabilityDTO].self, forKey: .capabilities) ?? []
        state = try container.decodeIfPresent(Int.self, forKey: .state)
        devices = try container.decodeIfPresent([StationDeviceDTO].self, forKey: .devices) ?? []
        stationItems = try container.decodeIfPresent([StationItemDTO].self, forKey: .stationItems) ?? []
        isLocalMode = try container.decodeIfPresent(Bool.self, forKey: .isLocalMode)
    }

    private enum CodingKeys: String, CodingKey {
        case stationID = "station_id"
        case locationID = "location_id"
        case name
        case publicName = "public_name"
        case latitude
        case longitude
        case timeZoneIdentifier = "timezone"
        case timezoneOffsetMinutes = "timezone_offset_minutes"
        case stationMeta = "station_meta"
        case createdEpoch = "created_epoch"
        case lastModifiedEpoch = "last_modified_epoch"
        case capabilities
        case state
        case devices
        case stationItems = "station_items"
        case isLocalMode = "is_local_mode"
    }
}
