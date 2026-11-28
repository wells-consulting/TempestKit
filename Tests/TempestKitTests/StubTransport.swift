//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

@testable import TempestKit

/// Returns saved responses in order and remembers every URL it was asked for,
/// so tests can count requests without hitting the network.
actor StubTransport: Transport {

    private var responses: [(data: Data, statusCode: Int)]
    private(set) var requestedURLs: [URL] = []

    init(_ responses: [(data: Data, statusCode: Int)]) {
        self.responses = responses
    }

    func get(_ url: URL) async throws(TempestError) -> (data: Data, statusCode: Int) {
        requestedURLs.append(url)
        guard !responses.isEmpty else {
            // Typed throws means the stub can't bring its own error type. A
            // test that asks for one more response than it queued lands here.
            throw TempestError.invalidResponse
        }
        return responses.removeFirst()
    }
}
