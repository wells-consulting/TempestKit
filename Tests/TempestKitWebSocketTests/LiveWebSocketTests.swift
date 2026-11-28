//
// TempestKitWebSocket
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

import TempestKit
import TempestKitWebSocket

// Runs only when TEMPEST_LIVE_TOKEN is set. The rest of the suite is offline.
struct LiveWebSocketTests {

    @Test(
        "The WebSocket delivers an observation",
        .enabled(if: ProcessInfo.processInfo.environment["TEMPEST_LIVE_TOKEN"] != nil),
        .timeLimit(.minutes(2))
    )
    func liveWebSocket() async throws {
        let token = try #require(ProcessInfo.processInfo.environment["TEMPEST_LIVE_TOKEN"])
        let client = TempestClient(userAgent: "TempestKit Live Test")
        let stations = try await client.stations(token: token)
        let device = try #require(
            stations.flatMap(\.devices).first { $0.deviceType == .tempest }
        )

        let socket = TempestWebSocket(token: token)
        let stream = try await socket.listen(to: [device.id])

        let first = try await withThrowingTaskGroup(
            of: TempestWebSocketEvent?.self
        ) { group in
            group.addTask {
                for try await event in stream {
                    if case .observation = event {
                        return event
                    }
                }
                return nil
            }
            group.addTask {
                try await Task.sleep(for: .seconds(90))
                return nil
            }

            let result = try await group.next() ?? nil
            group.cancelAll()
            return result
        }

        await socket.close()

        let event = try #require(first)
        guard case .observation(let deviceID, let reading) = event else {
            Issue.record("Expected an observation, got \(event)")
            return
        }
        #expect(deviceID == device.id)
        #expect(reading.timestamp > Date(timeIntervalSinceNow: -300))
    }

}
