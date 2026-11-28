//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

// These run only when TEMPEST_LIVE_TOKEN is set. The rest of the suite is
// offline.
struct LiveRESTTests {

    @Test(
        "The REST endpoints work with a live token",
        .enabled(if: ProcessInfo.processInfo.environment["TEMPEST_LIVE_TOKEN"] != nil)
    )
    func liveREST() async throws {
        let token = try #require(ProcessInfo.processInfo.environment["TEMPEST_LIVE_TOKEN"])
        let client = TempestClient(userAgent: "TempestKit Live Test")

        let stations = try await client.stations(token: token)
        let station = try #require(stations.first)
        try await Task.sleep(for: .seconds(2))

        let one = try await client.station(station.id, token: token)
        #expect(one?.id == station.id)
        try await Task.sleep(for: .seconds(2))

        let device = try #require(
            station.devices.first { $0.deviceType == .tempest }
        )
        let observations = try await client.deviceObservations(
            device: device.id,
            token: token
        )
        #expect(observations.type == "obs_st")
        #expect(observations.rows.isEmpty == false)
        try await Task.sleep(for: .seconds(2))

        let csv = try await client.deviceObservationsCSV(
            device: device.id,
            token: token
        )
        #expect(csv.contains("timestamp"))
        try await Task.sleep(for: .seconds(2))

        let conditions = try await client.conditions(station: station.id, token: token)
        #expect(conditions.stationID == station.id)
        try await Task.sleep(for: .seconds(2))

        let statistics = try await client.statistics(station: station.id, token: token)
        #expect(statistics.days.isEmpty == false)
        #expect(statistics.weeks.isEmpty == false)
        try await Task.sleep(for: .seconds(2))

        let forecast = try await client.forecast(
            station: station.id,
            units: .imperial,
            token: token
        )
        #expect(forecast.units == .imperial)
        #expect(forecast.days.isEmpty == false)
        #expect(forecast.days.first?.icon != nil)
    }
}
