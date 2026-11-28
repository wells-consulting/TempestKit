//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct BucketTests {

    private static let start = Date(timeIntervalSince1970: 1_791_460_800)

    private static func client(_ transport: any Transport) -> TempestClient {
        TempestClient(transport: transport)
    }

    @Test("Each bucket has the max range the API allows")
    func spans() {
        #expect(ObservationBucket.oneMinute.maxSpan == 86_400)
        #expect(ObservationBucket.fiveMinutes.maxSpan == 5 * 86_400)
        #expect(ObservationBucket.thirtyMinutes.maxSpan == 30 * 86_400)
        #expect(ObservationBucket.threeHours.maxSpan == 180 * 86_400)
        #expect(ObservationBucket.oneDay.maxSpan > 4 * 365 * 86_400)
    }

    @Test("A big bucket gets a long range in one request")
    func singleRequest() async throws {
        let transport = StubTransport([(Data(#"{"obs": []}"#.utf8), 200)])

        _ = try await Self.client(transport).observations(
            station: 1,
            range: Self.start...Self.start.addingTimeInterval(30 * 86_400),
            bucket: .oneDay,
            token: "abc",
        )

        let urls = await transport.requestedURLs
        #expect(urls.count == 1)
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.contains(URLQueryItem(name: "bucket", value: "1440")) == true)
    }

    @Test("A range longer than the bucket allows throws without a request")
    func tooLong() async throws {
        let transport = StubTransport([])

        await #expect(throws: TempestError.rangeTooLong(maxSpan: 30 * 86_400)) {
            try await Self.client(transport).observations(
                station: 1,
                range: Self.start...Self.start.addingTimeInterval(31 * 86_400),
                bucket: .thirtyMinutes,
                token: "abc",
            )
        }

        #expect(await transport.requestedURLs.isEmpty)
    }

    @Test("Windows fit the bucket")
    func bucketWindows() {
        let windows = ObservationBucket.thirtyMinutes.windows(
            for: Self.start...Self.start.addingTimeInterval(31 * 86_400),
        )

        #expect(windows.count == 2)
        #expect(windows[0].upperBound == Date(timeIntervalSince1970: 1_794_052_800))
    }

    @Test("Rows map by the field names in ob_fields")
    func fieldEcho() async throws {
        let payload = """
            {"ob_fields": ["air_temp", "timestamp"], "obs": [[42.5, 1791491452]]}
            """
        let transport = StubTransport([(Data(payload.utf8), 200)])

        let observations = try await Self.client(transport).observations(
            station: 1,
            range: Self.start...Self.start,
            token: "abc",
        )

        #expect(observations.count == 1)
        #expect(observations.first?.airTemperature == 42.5)
        #expect(observations.first?.timestamp == Date(timeIntervalSince1970: 1_791_491_452))

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.contains(where: { $0.name == "obs_fields" }) == false)
    }
}
