//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// One device row of a `/stations` response.
struct StationDeviceDTO: Decodable, Sendable {

    let id: Int
    let deviceType: String?
    let serialNumber: String?
    let firmwareRevision: String?
    let hardwareRevision: String?
    let notes: String?
    let meta: DeviceMetaDTO?
    let settings: DeviceSettingsDTO?

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        deviceType = try container.decodeIfPresent(String.self, forKey: .deviceType)
        serialNumber = try container.decodeIfPresent(String.self, forKey: .serialNumber)
        firmwareRevision = Self.revision(from: container, forKey: .firmwareRevision)
        hardwareRevision = Self.revision(from: container, forKey: .hardwareRevision)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        meta = try container.decodeIfPresent(DeviceMetaDTO.self, forKey: .meta)
        settings = try container.decodeIfPresent(DeviceSettingsDTO.self, forKey: .settings)
    }

    // Some devices send a revision as a number and some as a string. Either
    // way we keep it as a string. Anything else becomes nil so it doesn't
    // break the whole device.
    private static func revision(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> String? {
        do {
            return try container.decodeIfPresent(String.self, forKey: key)
        } catch {
            do {
                return try container.decodeIfPresent(Int.self, forKey: key)
                    .map(String.init)
            } catch {
                return nil
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id = "device_id"
        case deviceType = "device_type"
        case serialNumber = "serial_number"
        case firmwareRevision = "firmware_revision"
        case hardwareRevision = "hardware_revision"
        case notes
        case meta = "device_meta"
        case settings = "device_settings"
    }
}
