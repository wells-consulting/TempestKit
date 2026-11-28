//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

import TempestKit

@testable import TempestKitWebSocket

struct TempestWebSocketTests {

    @Test("Listening sends the requests in order")
    func requests() async throws {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })

        _ = try await socket.listen(to: [1, 2], rapidWind: true)

        let sent = await fake.sent()
        let requests = try sent.map {
            try JSONDecoder().decode(TestRequest.self, from: Data($0.utf8))
        }
        #expect(requests.map(\.type) == [
            "listen_start",
            "listen_start",
            "listen_rapid_start",
            "listen_rapid_start",
        ])
        #expect(requests.map(\.deviceID) == [1, 2, 1, 2])
        #expect(requests.allSatisfy { !$0.id.isEmpty })

        await socket.close()
    }

    @Test("The stream yields the parsed events")
    func events() async throws {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })
        let stream = try await socket.listen(to: [1])

        await fake.push(#"{"type":"ack","id":"1"}"#)
        await fake.push(#"{"type":"obs_st","device_id":1,"obs":[[1603481377,0,0.09,0.54,33,6,1014.8,28.8,71,16639,1.83,139,0,0,0,0,2.42,1]]}"#)

        var events: [TempestWebSocketEvent] = []
        for try await event in stream {
            events.append(event)
            if events.count == 2 {
                break
            }
        }
        await socket.close()

        #expect(events.count == 2)
        #expect(events.first == .acknowledged(id: "1"))
        guard case .observation(let deviceID, let observation) = events.last else {
            Issue.record("Expected an observation")
            return
        }
        #expect(deviceID == 1)
        #expect(observation.airTemperature == 28.8)
    }

    @Test("An API key goes in the query")
    func apiKeyURL() throws {
        let url = try #require(
            TempestWebSocket.url(credentialName: "api_key", credential: "abc")
        )
        #expect(url.query == "api_key=abc")
    }

    @Test("A lightning request goes out on the connection")
    func lightningRequest() async throws {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })
        let box = GeoBox(south: 37.28, west: -101.76, north: 41.32, east: -91.0)
        let request = LightningRequest(bounds: box, strikeType: .cloudToGround)

        _ = try await socket.listen(to: [], lightning: request)

        let sent = await fake.sent()
        #expect(sent.count == 1)
        let json = try #require(
            JSONSerialization.jsonObject(with: Data(sent[0].utf8)) as? [String: Any]
        )
        #expect(json["type"] as? String == "geo_strike_listen_start")
        #expect(json["lat_min"] as? Double == 37.28)
        #expect(json["lat_max"] as? Double == 41.32)
        #expect(json["lon_min"] as? Double == -101.76)
        #expect(json["lon_max"] as? Double == -91.0)
        #expect(json["strike_type"] as? String == "cg")
        #expect(json["id"] != nil)

        await socket.close()
    }

    @Test("Stopping a device sends both stop requests")
    func stopListening() async throws {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })

        _ = try await socket.listen(to: [1], rapidWind: true)
        try await socket.stopListening(to: 1)

        let sent = await fake.sent()
        #expect(sent.count == 4)
        #expect(sent[2].contains("\"type\":\"listen_stop\""))
        #expect(sent[3].contains("\"type\":\"listen_rapid_stop\""))

        await socket.close()
    }

    @Test("Close finishes the stream")
    func close() async throws {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })
        let stream = try await socket.listen(to: [1])

        await socket.close()

        var count = 0
        for try await _ in stream {
            count += 1
        }
        #expect(count == 0)
        #expect(await fake.isClosed)
    }

    @Test("An empty device list is refused")
    func emptyDevices() async {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })

        await #expect(throws: TempestError.invalidRequest) {
            _ = try await socket.listen(to: [])
        }
    }

    @Test("A second listen is refused while the first is open")
    func alreadyConnected() async throws {
        let fake = FakeConnection()
        let socket = TempestWebSocket(makeConnection: { _, _ in fake })

        _ = try await socket.listen(to: [1])
        await #expect(throws: TempestError.alreadyConnected) {
            _ = try await socket.listen(to: [2])
        }

        await socket.close()
    }

    @Test("A network error doesn't keep the URL")
    func networkError() throws {
        let url = try #require(URL(string: "wss://ws.weatherflow.com/swd/data?token=secret"))
        let error = URLError(.timedOut, userInfo: [
            NSURLErrorFailingURLErrorKey: url,
            "NSURLErrorFailingURLStringErrorKey": url.absoluteString,
        ])

        guard case .network(let urlError) = URLSessionWebSocketConnection.networkError(error) else {
            Issue.record("Expected a network error")
            return
        }
        #expect(urlError.userInfo["NSURLErrorFailingURLStringErrorKey"] == nil)
        #expect(urlError.userInfo[NSURLErrorFailingURLErrorKey] == nil)
    }
}

private struct TestRequest: Decodable {
    let type: String
    let deviceID: Int
    let id: String

    private enum CodingKeys: String, CodingKey {
        case type
        case deviceID = "device_id"
        case id
    }
}

// A connection the tests can feed messages into. `receive()` waits until a
// message arrives or the connection closes, so the client doesn't spin.
private actor FakeConnection: WebSocketConnection {

    private var sentText: [String] = []
    private var queue: [String] = []
    private var receiveWaiter: CheckedContinuation<String?, Never>?
    private(set) var isClosed = false

    func open() async throws(TempestError) {}

    func send(_ text: String) async throws(TempestError) {
        sentText.append(text)
    }

    func receive() async throws(TempestError) -> String {
        if !queue.isEmpty {
            return queue.removeFirst()
        }
        if isClosed {
            throw TempestError.network(URLError(.cancelled))
        }

        let text = await withCheckedContinuation { continuation in
            receiveWaiter = continuation
        }
        guard let text else {
            throw TempestError.network(URLError(.cancelled))
        }
        return text
    }

    func close() async {
        isClosed = true
        receiveWaiter?.resume(returning: nil)
        receiveWaiter = nil
    }

    func push(_ text: String) {
        if let waiter = receiveWaiter {
            receiveWaiter = nil
            waiter.resume(returning: text)
        } else {
            queue.append(text)
        }
    }

    func sent() -> [String] {
        sentText
    }
}
