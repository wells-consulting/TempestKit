//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import TempestKit

/// The station's live feed over a WebSocket.
///
/// Open one connection per app. `listen(to:rapidWind:)` opens it, starts the
/// devices you name, and returns one event stream. The server drops a
/// connection after ten minutes with nothing to say, so listen to at least one
/// device. There's no automatic reconnect; make a new client if the stream
/// ends.
public actor TempestWebSocket {

    private let credential: String
    private let credentialName: String
    private let userAgent: String
    private let makeConnection: @Sendable (URL, String) -> any WebSocketConnection

    private var connection: (any WebSocketConnection)?
    private var receiveTask: Task<Void, Never>?
    private var continuation: AsyncThrowingStream<TempestWebSocketEvent, any Error>.Continuation?
    private var listening: Set<WeatherStation.Device.ID> = []
    private var rapidDevices: Set<WeatherStation.Device.ID> = []

    /// - Parameters:
    ///   - token: Your personal access token or OAuth token.
    ///   - userAgent: Sent with the handshake. Set it to your app's name if
    ///     you want WeatherFlow to know who's calling.
    public init(token: String, userAgent: String = "TempestKit") {
        self.credential = token
        self.credentialName = "token"
        self.userAgent = userAgent
        self.makeConnection = { url, userAgent in
            URLSessionWebSocketConnection(url: url, userAgent: userAgent)
        }
    }

    /// - Parameters:
    ///   - apiKey: The API key from WeatherFlow's developer page.
    ///   - userAgent: Sent with the handshake.
    public init(apiKey: String, userAgent: String = "TempestKit") {
        self.credential = apiKey
        self.credentialName = "api_key"
        self.userAgent = userAgent
        self.makeConnection = { url, userAgent in
            URLSessionWebSocketConnection(url: url, userAgent: userAgent)
        }
    }

    // So tests can pass a fake connection
    init(
        credential: String = "",
        credentialName: String = "token",
        userAgent: String = "TempestKit",
        makeConnection: @escaping @Sendable (URL, String) -> any WebSocketConnection
    ) {
        self.credential = credential
        self.credentialName = credentialName
        self.userAgent = userAgent
        self.makeConnection = makeConnection
    }

    /// Opens the connection and returns its events.
    ///
    /// Call this once. The stream finishes when the connection closes, and
    /// iterating it is what keeps the socket alive. Calling `close()` or
    /// letting the stream go finishes the connection.
    ///
    /// - Parameters:
    ///   - devices: The devices to listen to. At least one, unless you only
    ///     want the lightning feed.
    ///   - rapidWind: Also ask for the 3 second wind samples.
    ///   - lightning: Also watch a box for lightning strikes.
    /// - Returns: The event stream.
    /// - Throws: `TempestError` when the connection or a request fails.
    public func listen(
        to devices: [WeatherStation.Device.ID],
        rapidWind: Bool = false,
        lightning: LightningRequest? = nil
    ) async throws(TempestError) -> AsyncThrowingStream<TempestWebSocketEvent, any Error> {
        guard !devices.isEmpty || lightning != nil else { throw .invalidRequest }
        guard connection == nil else { throw .alreadyConnected }
        guard
            let url = Self.url(
                credentialName: credentialName,
                credential: credential
            )
        else {
            throw .invalidRequest
        }

        let connection = makeConnection(url, userAgent)
        self.connection = connection
        do {
            try await connection.open()
        } catch {
            self.connection = nil
            throw error
        }

        let (stream, continuation) = AsyncThrowingStream.makeStream(
            of: TempestWebSocketEvent.self
        )
        self.continuation = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.close() }
        }
        receiveTask = Task { [weak self] in
            await self?.receiveLoop(continuation: continuation)
        }

        do {
            for device in devices {
                try await send(.listen(type: .listenStart, deviceID: device))
                listening.insert(device)
            }
            if rapidWind {
                for device in devices {
                    try await send(.listen(type: .listenRapidStart, deviceID: device))
                    rapidDevices.insert(device)
                }
            }
            if let lightning {
                try await send(.lightning(lightning))
            }
        } catch {
            await close()
            throw error
        }

        return stream
    }

    /// Stops one device's messages. The connection stays open for the others.
    ///
    /// - Parameter device: The device to stop listening to.
    /// - Throws: `TempestError` when the request fails.
    public func stopListening(to device: WeatherStation.Device.ID) async throws(TempestError) {
        guard connection != nil else { return }

        if listening.contains(device) {
            try await send(.listen(type: .listenStop, deviceID: device))
            listening.remove(device)
        }
        if rapidDevices.contains(device) {
            try await send(.listen(type: .listenRapidStop, deviceID: device))
            rapidDevices.remove(device)
        }
    }

    /// Closes the connection and finishes the stream.
    public func close() async {
        receiveTask?.cancel()
        receiveTask = nil
        await connection?.close()
        connection = nil
        continuation?.finish()
        continuation = nil
        listening.removeAll()
        rapidDevices.removeAll()
    }

    private func send(_ request: Request) async throws(TempestError) {
        guard let connection else { throw .invalidRequest }

        let data: Data
        do {
            data = try JSONEncoder().encode(request)
        } catch {
            throw .invalidRequest
        }
        guard let text = String(data: data, encoding: .utf8) else {
            throw .invalidRequest
        }
        try await connection.send(text)
    }

    private func receiveLoop(
        continuation: AsyncThrowingStream<TempestWebSocketEvent, any Error>.Continuation
    ) async {
        do {
            while !Task.isCancelled {
                guard let text = try await connection?.receive() else { break }
                for event in WebSocketEventParser().parse(text) {
                    continuation.yield(event)
                }
            }
            continuation.finish()
        } catch {
            continuation.finish(throwing: error)
        }

        await close()
    }

    static func url(credentialName: String, credential: String) -> URL? {
        guard var components = URLComponents(string: "wss://ws.weatherflow.com/swd/data") else {
            return nil
        }
        components.queryItems = [URLQueryItem(name: credentialName, value: credential)]
        return components.url
    }
}

private enum RequestType: String, Sendable {
    case listenStart = "listen_start"
    case listenStop = "listen_stop"
    case listenRapidStart = "listen_rapid_start"
    case listenRapidStop = "listen_rapid_stop"
}

private enum Request: Encodable, Sendable {

    case listen(type: RequestType, deviceID: WeatherStation.Device.ID)
    case lightning(LightningRequest)

    private enum CodingKeys: String, CodingKey {
        case type
        case deviceID = "device_id"
        case id
        case latMin = "lat_min"
        case latMax = "lat_max"
        case lonMin = "lon_min"
        case lonMax = "lon_max"
        case strikeType = "strike_type"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .listen(let type, let deviceID):
            try container.encode(type.rawValue, forKey: .type)
            try container.encode(deviceID, forKey: .deviceID)
            try container.encode(UUID().uuidString, forKey: .id)
        case .lightning(let request):
            try container.encode("geo_strike_listen_start", forKey: .type)
            try container.encode(request.bounds.south, forKey: .latMin)
            try container.encode(request.bounds.north, forKey: .latMax)
            try container.encode(request.bounds.west, forKey: .lonMin)
            try container.encode(request.bounds.east, forKey: .lonMax)
            try container.encode(request.strikeType.rawValue, forKey: .strikeType)
            try container.encode(Int.random(in: 1...1_000_000_000), forKey: .id)
        }
    }
}
