//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Things that can go wrong talking to the API, or listening for the
/// station's broadcasts.
///
/// The messages are short on purpose. Your app knows its users and should
/// write the messages they see.
public enum TempestError: Error, Equatable, LocalizedError {

    /// We couldn't build a URL from the parameters
    case invalidRequest

    /// The range is longer than one request can cover at that bucket size.
    /// Split it with `ObservationBucket.windows(for:)`.
    case rangeTooLong(maxSpan: TimeInterval)

    /// The request never finished: no connection, a timeout, a dropped
    /// connection. `code` and the rest of the URL error say which.
    case network(URLError)

    /// We couldn't listen for the station's broadcasts on `port`. Usually
    /// something else on the device already has it.
    case listeningFailed(port: UInt16, reason: String)

    /// The WebSocket already has a connection open.
    case alreadyConnected

    /// The response wasn't an HTTP response
    case invalidResponse

    /// The API didn't accept the token (a 401)
    case unauthorized

    /// We're calling too fast (a 429). The limit isn't published, but when we
    /// hit it, it cleared within a minute.
    case rateLimited

    /// The API returned some other non-2xx status
    case httpStatus(code: Int, path: String)

    /// The response wasn't what we expected. `message` is what the decoder or
    /// the text check said went wrong.
    case decoding(path: String, message: String)

    /// The station didn't send back any usable observation
    case noObservation

    /// A short message for the error.
    public var errorDescription: String? {
        switch self {
        case .invalidRequest:
            "Unable to build the weather request."
        case .rangeTooLong:
            "That's more history than one request can get."
        case .network(let error):
            "Unable to reach the weather service. \(error.localizedDescription)"
        case .listeningFailed(let port, _):
            "Unable to listen for live readings on port \(port)."
        case .alreadyConnected:
            "The live connection is already open."
        case .invalidResponse:
            "The weather service sent back something that isn't HTTP."
        case .unauthorized:
            "The weather service didn't accept the token."
        case .rateLimited:
            "The weather service says we're asking too often."
        case .httpStatus(let code, let path):
            "The weather service returned status \(code) for \(path)."
        case .decoding(let path, _):
            "Unable to read the weather service's response to \(path)."
        case .noObservation:
            "The station has no observations."
        }
    }
}
