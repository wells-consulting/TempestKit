//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct DeviceObservationClientTests {

    private static let payload = """
        {
          "status": {"status_code": 0},
          "device_id": 60526,
          "type": "obs_st",
          "source": "cache",
          "summary": {
            "pressure_trend": "steady",
            "strike_count_1h": 2,
            "strike_count_3h": 5,
            "precip_total_1h": 0.2,
            "strike_last_dist": 12,
            "strike_last_epoch": 1791490000,
            "precip_accum_local_yesterday": 1.2,
            "precip_accum_local_yesterday_final": 1.3,
            "precip_analysis_type_yesterday": 1,
            "feels_like": 21,
            "heat_index": 22,
            "wind_chill": 20,
            "dew_point": 10,
            "wet_bulb_temperature": 15,
            "wet_bulb_globe_temperature": 18,
            "air_density": 1.2,
            "delta_t": 5,
            "precip_minutes_local_day": 3,
            "precip_minutes_local_yesterday": 4
          },
          "obs": [[1791491452, 0, 0.1, 0.2, 90, 3, 1006.4, 22.0, 50, 1000, 1, 100, 0, 0, 0, 0, 2.8, 1, 0.5, 0.1, 0.2, 1]]
        }
        """

    private static func client(_ transport: any Transport) -> TempestClient {
        TempestClient(transport: transport)
    }

    @Test("Device observations map the rows and the summary")
    func observations() async throws {
        let transport = StubTransport([(Data(Self.payload.utf8), 200)])

        let result = try await Self.client(transport).deviceObservations(
            device: 60526,
            token: "abc",
        )

        #expect(result.status?.code == 0)
        #expect(result.deviceID == 60526)
        #expect(result.type == "obs_st")
        #expect(result.source == "cache")
        #expect(result.rows.count == 1)
        #expect(result.rows.first?.airTemperature == 22)
        #expect(result.rows.first?.precipitationAnalysis == .rainCheckShown)
        #expect(result.summary?.lightningStrikeCountLastHour == 2)
        #expect(result.summary?.precipitationLastHour == 0.2)
        #expect(result.summary?.precipitationAnalysisTypeYesterday == .rainCheckShown)
        #expect(result.summary?.calculated?.pressureTrend == .steady)
        #expect(result.summary?.calculated?.feelsLike == 21)
        #expect(result.summary?.precipitationMinutesYesterday == 4)

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.path == "/swd/rest/observations/device/60526")
        #expect(components.queryItems?.contains(URLQueryItem(name: "day_offset", value: "0")) == false)
    }

    @Test("A day offset is sent as day_offset")
    func dayRange() async throws {
        let transport = StubTransport([(Data(Self.payload.utf8), 200)])

        _ = try await Self.client(transport).deviceObservations(
            device: 60526,
            range: .day(offset: 1),
            token: "abc",
        )

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.contains(URLQueryItem(name: "day_offset", value: "1")) == true)
    }

    @Test("A range is sent as time_start and time_end")
    func dateRange() async throws {
        let transport = StubTransport([(Data(Self.payload.utf8), 200)])
        let start = Date(timeIntervalSince1970: 1_791_460_800)

        _ = try await Self.client(transport).deviceObservations(
            device: 60526,
            range: .range(start...start.addingTimeInterval(86_400)),
            token: "abc",
        )

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.contains(URLQueryItem(name: "time_start", value: "1791460800")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "time_end", value: "1791547200")) == true)
    }

    @Test("A range longer than five days never reaches the network")
    func longRange() async {
        let transport = StubTransport([])
        let start = Date(timeIntervalSince1970: 1_791_460_800)

        await #expect(throws: TempestError.rangeTooLong(maxSpan: DeviceObservationRange.maxSpan)) {
            _ = try await Self.client(transport).deviceObservations(
                device: 1,
                range: .range(start...start.addingTimeInterval(6 * 86_400)),
                token: "abc",
            )
        }
        #expect(await transport.requestedURLs.isEmpty)
    }

    @Test("A negative day offset never reaches the network")
    func negativeDay() async {
        let transport = StubTransport([])

        await #expect(throws: TempestError.invalidRequest) {
            _ = try await Self.client(transport).deviceObservations(
                device: 1,
                range: .day(offset: -1),
                token: "abc",
            )
        }
        #expect(await transport.requestedURLs.isEmpty)
    }

    @Test("A row type we don't know keeps its name and drops the rows")
    func unknownType() async throws {
        let payload = #"{"device_id": 1, "type": "obs_future", "obs": [[1, 2, 3]]}"#
        let transport = StubTransport([(Data(payload.utf8), 200)])

        let result = try await Self.client(transport).deviceObservations(
            device: 1,
            token: "abc",
        )

        #expect(result.type == "obs_future")
        #expect(result.rows.isEmpty)
    }

    @Test("A missing row type leaves the rows empty")
    func missingType() async throws {
        let transport = StubTransport([(Data(#"{"device_id": 1, "obs": []}"#.utf8), 200)])

        let result = try await Self.client(transport).deviceObservations(
            device: 1,
            token: "abc",
        )

        #expect(result.type.isEmpty)
        #expect(result.rows.isEmpty)
    }

    @Test("The CSV method asks for CSV and returns the text")
    func csv() async throws {
        let text = "timestamp,air_temp\n1791491452,22.0\n"
        let transport = StubTransport([(Data(text.utf8), 200)])

        let result = try await Self.client(transport).deviceObservationsCSV(
            device: 60526,
            token: "abc",
        )

        #expect(result == text)

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.path == "/swd/rest/observations/device/60526")
        #expect(components.queryItems?.contains(URLQueryItem(name: "format", value: "csv")) == true)
    }

    @Test("A JSON response to the CSV method is a decoding error")
    func csvJSON() async {
        let transport = StubTransport([(Data(#"{"obs":[]}"#.utf8), 200)])

        await #expect(throws: TempestError.decoding(
            path: "observations/device/1",
            message: "Expected CSV, got JSON.",
        )) {
            _ = try await Self.client(transport).deviceObservationsCSV(
                device: 1,
                token: "abc",
            )
        }
    }

    @Test("A response that isn't UTF-8 is a decoding error")
    func csvNotText() async {
        let transport = StubTransport([(Data([0xFF]), 200)])

        await #expect(throws: TempestError.decoding(
            path: "observations/device/1",
            message: "The response wasn't UTF-8 text.",
        )) {
            _ = try await Self.client(transport).deviceObservationsCSV(
                device: 1,
                token: "abc",
            )
        }
    }

    @Test("A device 404 throws with the path")
    func notFound() async {
        let transport = StubTransport([(Data(), 404)])

        await #expect(throws: TempestError.httpStatus(
            code: 404,
            path: "observations/device/1",
        )) {
            _ = try await Self.client(transport).deviceObservations(
                device: 1,
                token: "abc",
            )
        }
    }
}
