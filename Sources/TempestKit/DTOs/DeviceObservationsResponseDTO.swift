//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// An `/observations/device/{id}` response, exactly as the API sends it.
///
/// Each row is a plain array of numbers, the same shape as the UDP and
/// WebSocket rows. `type` says which layout the rows use.
struct DeviceObservationsResponseDTO: Decodable, Sendable {

    let status: ResponseStatusDTO?
    let deviceID: Int?
    let type: String?
    let source: String?
    let summary: DeviceObservationSummaryDTO?
    let observations: [[Double?]]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(ResponseStatusDTO.self, forKey: .status)
        deviceID = try container.decodeIfPresent(Int.self, forKey: .deviceID)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        summary = try container.decodeIfPresent(DeviceObservationSummaryDTO.self, forKey: .summary)
        observations = try container.decodeIfPresent([[Double?]].self, forKey: .observations) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case status
        case deviceID = "device_id"
        case type
        case source
        case summary
        case observations = "obs"
    }
}
