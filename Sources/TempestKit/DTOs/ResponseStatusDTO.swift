//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `status` object in a response.
struct ResponseStatusDTO: Decodable, Sendable {

    let code: Int
    let message: String?

    private enum CodingKeys: String, CodingKey {
        case code = "status_code"
        case message = "status_message"
    }
}
