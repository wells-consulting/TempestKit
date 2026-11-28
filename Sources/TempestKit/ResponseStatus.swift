//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The `status` object the API puts in every response.
public struct ResponseStatus: Hashable, Sendable {

    /// 0 on success
    public let code: Int
    /// The API's message, when it sends one.
    public let message: String?

    /// Creates a status from the values the API sends.
    ///
    /// - Parameters:
    ///   - code: The status code. 0 means success.
    ///   - message: The API's message, when it sends one.
    public init(code: Int, message: String? = nil) {
        self.code = code
        self.message = message
    }
}
