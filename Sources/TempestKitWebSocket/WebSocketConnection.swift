//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import TempestKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// Everything the live feed needs from the socket. It's a protocol so tests can
// hand the client saved messages and count requests.
protocol WebSocketConnection: Sendable {

    func open() async throws(TempestError)
    func send(_ text: String) async throws(TempestError)
    func receive() async throws(TempestError) -> String
    func close() async
}

struct URLSessionWebSocketConnection: WebSocketConnection {

    private let task: URLSessionWebSocketTask

    init(url: URL, userAgent: String) {
        var request = URLRequest(url: url)
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        self.task = URLSession.shared.webSocketTask(with: request)
    }

    func open() async throws(TempestError) {
        task.resume()
    }

    func send(_ text: String) async throws(TempestError) {
        do {
            try await task.send(.string(text))
        } catch {
            throw Self.networkError(error)
        }
    }

    func receive() async throws(TempestError) -> String {
        do {
            let message = try await task.receive()
            switch message {
            case .string(let text):
                return text
            case .data(let data):
                guard let text = String(data: data, encoding: .utf8) else {
                    throw TempestError.decoding(
                        path: "ws",
                        message: "The message wasn't UTF-8."
                    )
                }
                return text
            @unknown default:
                throw TempestError.decoding(
                    path: "ws",
                    message: "Unknown WebSocket message."
                )
            }
        } catch let error as TempestError {
            throw error
        } catch {
            throw Self.networkError(error)
        }
    }

    func close() async {
        task.cancel(with: .normalClosure, reason: nil)
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
