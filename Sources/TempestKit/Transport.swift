//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Everything the client needs from the network. It's a protocol so tests can
/// swap in saved responses and count requests.
protocol Transport: Sendable {

    func get(_ url: URL) async throws(TempestError) -> (data: Data, statusCode: Int)
}

// On Linux, URLSession lives in FoundationNetworking. That's the only extra
// import we need there.

struct URLSessionTransport: Transport {

    let userAgent: String

    // The download stays off whatever actor called us. Without this, Swift 6.2
    // runs a nonisolated async function on the caller's actor, so a call from a
    // view model would hit the network on the main thread.
    @concurrent
    func get(_ url: URL) async throws(TempestError) -> (data: Data, statusCode: Int) {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            // URLSession reports URLError, but the signature isn't typed, so
            // anything else gets the same treatment.
            throw Self.networkError(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw TempestError.invalidResponse
        }
        return (data, http.statusCode)
    }

    // The URL carries the token, so it doesn't belong in an error.
    static func networkError(_ error: any Error) -> TempestError {
        guard let urlError = error as? URLError else {
            return .network(URLError(.unknown))
        }
        var userInfo = urlError.userInfo
        userInfo.removeValue(forKey: NSURLErrorFailingURLErrorKey)
        userInfo.removeValue(forKey: "NSURLErrorFailingURLStringErrorKey")
        return .network(URLError(urlError.code, userInfo: userInfo))
    }
}
