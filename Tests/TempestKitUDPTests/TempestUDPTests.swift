//
// TempestKitUDP
// Copyright 2026 Wells Consulting. MIT licensed.
//

#if canImport(Network)
import Foundation
import Testing

import TempestKit

@testable import TempestKitUDP

struct TempestUDPTests {

    @Test("Broadcasts come through the stream")
    func passesBroadcastsThrough() async throws {
        let rainStart = Date(timeIntervalSince1970: 1_795_042_900)
        let message = TempestBroadcast.rainStart(
            serialNumber: "SK-00000000",
            hubSerialNumber: "HB-00000000",
            date: rainStart
        )
        let udp = TempestUDP(source: FakeSource(messages: [message]))

        var received: [TempestBroadcast] = []
        for try await broadcast in try udp.listen() {
            received.append(broadcast)
        }
        #expect(received == [message])
    }

    @Test("A port of zero is refused")
    func portZero() {
        let udp = TempestUDP(station: 1, hubSerialNumber: "HB-00000000", port: 0)
        #expect(throws: TempestError.self) {
            _ = try udp.listen()
        }
    }
}

private struct FakeSource: BroadcastSource {

    let messages: [TempestBroadcast]

    func broadcasts() throws(TempestError) -> AsyncThrowingStream<TempestBroadcast, any Error> {
        AsyncThrowingStream { continuation in
            for message in messages {
                continuation.yield(message)
            }
            continuation.finish()
        }
    }
}
#endif
