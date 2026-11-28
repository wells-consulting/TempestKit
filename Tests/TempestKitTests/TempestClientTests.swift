//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct TempestClientTests {

    private static let row: [Double?] = [
        1_791_491_452, 1, 0.0, 0.1, 1.1, 122, 994.9, 1007.1, 42.5, 16,
        96_294, 8.88, 802, 0.0, 0.0, 0, 0, 0, 0.0, 0.0,
    ]

    private static let stationsPayload = """
        {"status": {"status_code": 0, "status_message": "SUCCESS"}, "stations": [{
            "station_id": 100001, "name": "Test Station",
            "latitude": 37.77493, "longitude": -122.41942,
            "timezone": "America/Los_Angeles", "created_epoch": 1791481417,
            "devices": [{"device_id": 200002, "device_type": "ST", "firmware_revision": 193}]
        }]}
        """

    private static let stationPayload = """
        {"status": {"status_code": 0, "status_message": "SUCCESS"}, "stations": [{
            "station_id": 100001, "name": "Test Station",
            "latitude": 37.77493, "longitude": -122.41942,
            "timezone": "America/Los_Angeles", "created_epoch": 1791481417
        }]}
        """

    private static let forecastPayload = """
        {"forecast": {
            "hourly": [{"time": 1791496800, "icon": "clear-day", "air_temperature": 41.0}],
            "daily": [{"day_start_local": 1791490800, "icon": "clear-day", "air_temp_high": 41.0, "air_temp_low": 24.0}]
        }}
        """

    private static func client(_ transport: any Transport) -> TempestClient {
        TempestClient(transport: transport)
    }

    private static func observationsPayload(rows: [[Double?]]) throws -> Data {
        try JSONEncoder().encode(ObservationsPayload(obs: rows))
    }

    private struct ObservationsPayload: Encodable {
        let obs: [[Double?]]
    }

    // MARK: - Stations

    @Test("Stations are requested with the token")
    func stationsRequest() async throws {
        let transport = StubTransport([(Data(Self.stationsPayload.utf8), 200)])
        let stations = try await Self.client(transport).stations(token: "abc")

        #expect(stations.count == 1)
        #expect(stations.first?.name == "Test Station")

        let urls = await transport.requestedURLs
        let url = try #require(urls.first)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(components.path == "/swd/rest/stations")
        #expect(components.queryItems?.contains(URLQueryItem(name: "token", value: "abc")) == true)
    }

    @Test("A station set keeps the API's status")
    func stationSetRequest() async throws {
        let transport = StubTransport([(Data(Self.stationsPayload.utf8), 200)])
        let set = try await Self.client(transport).stationSet(token: "abc")

        #expect(set.status?.code == 0)
        #expect(set.status?.message == "SUCCESS")
        #expect(set.stations.count == 1)
    }

    @Test("One station is requested by ID")
    func stationRequest() async throws {
        let transport = StubTransport([(Data(Self.stationPayload.utf8), 200)])
        let station = try await Self.client(transport).station(100_001, token: "abc")

        #expect(station?.name == "Test Station")

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.path == "/swd/rest/stations/100001")
    }

    @Test("An empty station response is nil")
    func stationMissing() async throws {
        let transport = StubTransport([(Data(#"{"stations": []}"#.utf8), 200)])
        let station = try await Self.client(transport).station(1, token: "abc")
        #expect(station == nil)
    }

    @Test("A station 404 throws with the path")
    func stationNotFound() async throws {
        let transport = StubTransport([(Data(), 404)])

        await #expect(throws: TempestError.httpStatus(code: 404, path: "stations/1")) {
            _ = try await Self.client(transport).station(1, token: "abc")
        }
    }

    // MARK: - Observations

    @Test("A day of observations is one request")
    func observationsRequest() async throws {
        let transport = StubTransport([(try Self.observationsPayload(rows: [Self.row]), 200)])
        let start = Date(timeIntervalSince1970: 1_791_460_800)

        let observations = try await Self.client(transport).observations(
            station: 100_001,
            range: start...start.addingTimeInterval(86_400),
            token: "abc",
        )

        #expect(observations.count == 1)
        #expect(observations.allSatisfy { $0.stationID == 100_001 })

        let urls = await transport.requestedURLs
        #expect(urls.count == 1)
        let first = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(first.path == "/swd/rest/observations/stn/100001")
        #expect(first.queryItems?.contains(URLQueryItem(name: "time_start", value: "1791460800")) == true)
        #expect(first.queryItems?.contains(URLQueryItem(name: "time_end", value: "1791547200")) == true)
    }

    @Test("An empty response is no observations, not an error")
    func emptyObservations() async throws {
        let transport = StubTransport([(try Self.observationsPayload(rows: []), 200)])
        let observations = try await Self.client(transport).observations(
            station: 1,
            range: Date.now...Date.now,
            token: "abc",
        )
        #expect(observations.isEmpty)
    }

    @Test("Station observations keep the source and units")
    func stationObservationsResponse() async throws {
        let payload = """
            {
              "status": {"status_code": 0, "status_message": "Success"},
              "station_id": 100001,
              "type": "obs_station",
              "source": "db",
              "units": {
                "units_temp": "c", "units_wind": "mps", "units_pressure": "mb",
                "units_precip": "mm", "units_distance": "km"
              },
              "ob_fields": ["timestamp", "air_temp"],
              "obs": [[1791491452, 22.5]]
            }
            """
        let transport = StubTransport([(Data(payload.utf8), 200)])

        let result = try await Self.client(transport).latestStationObservations(
            station: 100_001,
            token: "abc",
        )

        #expect(result.status?.code == 0)
        #expect(result.stationID == 100_001)
        #expect(result.type == "obs_station")
        #expect(result.source == "db")
        #expect(result.units?.temperature == .celsius)
        #expect(result.fields == ["timestamp", "air_temp"])
        #expect(result.rows.count == 1)
        #expect(result.rows.first?.airTemperature == 22.5)
    }

    @Test("Latest observation skips a bad newest row")
    func latestObservationSkipsGap() async throws {
        var gap = Self.row
        gap[8] = nil

        let transport = StubTransport([(try Self.observationsPayload(rows: [Self.row, gap]), 200)])
        let observation = try await Self.client(transport).latestObservation(station: 1, token: "abc")

        #expect(observation.timestamp == Date(timeIntervalSince1970: 1_791_491_452))
    }

    @Test("No rows throws noObservation")
    func latestObservationMissing() async throws {
        let transport = StubTransport([(try Self.observationsPayload(rows: []), 200)])

        await #expect(throws: TempestError.noObservation) {
            try await Self.client(transport).latestObservation(station: 1, token: "abc")
        }
    }

    // MARK: - Forecast

    @Test("The forecast asks for metric")
    func forecastRequest() async throws {
        let transport = StubTransport([(Data(Self.forecastPayload.utf8), 200)])

        let forecast = try await Self.client(transport).forecast(station: 100_001, token: "abc")

        #expect(forecast.days.count == 1)

        let urls = await transport.requestedURLs
        #expect(urls.count == 1)
        let url = try #require(urls.first)
        let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
        #expect(forecast.units == .metric)
        #expect(components.path == "/swd/rest/better_forecast")
        #expect(components.queryItems?.contains(URLQueryItem(name: "station_id", value: "100001")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "units_temp", value: "c")) == true)
    }

    @Test("The forecast can ask for other units")
    func forecastUnits() async throws {
        let transport = StubTransport([(Data(Self.forecastPayload.utf8), 200)])

        let forecast = try await Self.client(transport).forecast(
            station: 100_001,
            units: .imperial,
            token: "abc",
        )

        #expect(forecast.units == .imperial)

        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.queryItems?.contains(URLQueryItem(name: "units_temp", value: "f")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "units_wind", value: "mph")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "units_pressure", value: "inhg")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "units_precip", value: "in")) == true)
        #expect(components.queryItems?.contains(URLQueryItem(name: "units_distance", value: "mi")) == true)
    }

    @Test("Two forecast calls are two requests")
    func forecastNotCached() async throws {
        let transport = StubTransport([
            (Data(Self.forecastPayload.utf8), 200),
            (Data(Self.forecastPayload.utf8), 200),
        ])
        let client = Self.client(transport)

        _ = try await client.forecast(station: 100_001, token: "abc")
        _ = try await client.forecast(station: 100_001, token: "abc")

        #expect(await transport.requestedURLs.count == 2)
    }

    @Test("Two stations are two forecasts")
    func forecastKeys() async throws {
        let transport = StubTransport([
            (Data(Self.forecastPayload.utf8), 200),
            (Data(Self.forecastPayload.utf8), 200),
        ])
        let client = Self.client(transport)

        _ = try await client.forecast(station: 100_001, token: "abc")
        _ = try await client.forecast(station: 100_002, token: "abc")

        let urls = await transport.requestedURLs
        #expect(urls.count == 2)
        let second = try #require(URLComponents(url: urls.last!, resolvingAgainstBaseURL: false))
        #expect(second.queryItems?.contains(URLQueryItem(name: "station_id", value: "100002")) == true)
    }

    // MARK: - Conditions and statistics

    @Test("Conditions come from /observations/station")
    func conditionsRequest() async throws {
        let payload = """
            {"station_id": 1, "obs": [{"timestamp": 1791491452, "air_temperature": 42.5}]}
            """
        let transport = StubTransport([(Data(payload.utf8), 200)])

        let conditions = try await Self.client(transport).conditions(station: 1, token: "abc")

        #expect(conditions.airTemperature == 42.5)
        let urls = await transport.requestedURLs
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.path == "/swd/rest/observations/station/1")
    }

    @Test("No conditions throws noObservation")
    func conditionsMissing() async throws {
        let transport = StubTransport([(Data(#"{"station_id": 1, "obs": []}"#.utf8), 200)])

        await #expect(throws: TempestError.noObservation) {
            try await Self.client(transport).conditions(station: 1, token: "abc")
        }
    }

    @Test("Statistics are one request for the whole span")
    func statisticsRequest() async throws {
        let payload = """
            {"station_id": 1, "first_ob_local_day": "2026-11-09", "stats_day": [["2026-11-09", 1007.1]]}
            """
        let transport = StubTransport([(Data(payload.utf8), 200)])

        let statistics = try await Self.client(transport).statistics(station: 1, token: "abc")

        #expect(statistics.days.first?.pressure == 1007.1)
        #expect(statistics.days.first?.date == DateComponents(year: 2026, month: 11, day: 9))
        let urls = await transport.requestedURLs
        #expect(urls.count == 1)
        let components = try #require(URLComponents(url: urls[0], resolvingAgainstBaseURL: false))
        #expect(components.path == "/swd/rest/stats/station/1")
    }

    // MARK: - Failures

    @Test("A 401 throws unauthorized")
    func unauthorized() async throws {
        let transport = StubTransport([(Data(), 401)])

        await #expect(throws: TempestError.unauthorized) {
            try await Self.client(transport).stations(token: "abc")
        }
    }

    @Test("A 429 throws rateLimited")
    func rateLimited() async throws {
        let transport = StubTransport([(Data(), 429)])

        await #expect(throws: TempestError.rateLimited) {
            try await Self.client(transport).stations(token: "abc")
        }
    }

    @Test("Any other bad status throws with its code and path")
    func httpError() async throws {
        let transport = StubTransport([(Data(), 503)])

        await #expect(throws: TempestError.httpStatus(code: 503, path: "stations")) {
            try await Self.client(transport).stations(token: "abc")
        }
    }

    @Test("JSON we can't read throws decoding with the path, not the token")
    func decodingError() async throws {
        let transport = StubTransport([(Data("not json".utf8), 200)])

        do {
            _ = try await Self.client(transport).stations(token: "abc")
            Issue.record("Expected a decoding error")
        } catch let TempestError.decoding(path, message) {
            #expect(path == "stations")
            #expect(!message.contains("abc"))
        }
    }
}
