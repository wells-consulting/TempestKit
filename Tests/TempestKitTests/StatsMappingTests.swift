//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct StatsMappingTests {

    // A real stats_day row: the date, then 33 numbers
    private static let payload = """
        {
          "station_id": 100001,
          "type": "station_stats",
          "first_ob_day_local": "2025-10-08",
          "last_ob_day_local": "2026-11-10",
          "stats_day": [[
            "2025-10-08",
            1007.1, 1009.0, 1004.2, 42.5, 44.1, 21.0, 16, 22, 10,
            96294, 100000, 0, 8.88, 9.5, 0, 802, 900, 0,
            0.1, 1.1, 0.0, 122, 60, 2, 8.5, 1440, 3.2,
            0.02, 0.03, 3, 4, 1, 2
          ]]
        }
        """

    @Test("Statistics map the first/last days and each row")
    func mapping() throws {
        let response = try JSONDecoder().decode(StationStatsResponseDTO.self, from: Data(Self.payload.utf8))
        let statistics = StationStatistics(dto: response)

        #expect(statistics.status == nil)
        #expect(statistics.type == "station_stats")
        #expect(statistics.stationID == 100_001)
        #expect(statistics.firstObservationDay == DateComponents(year: 2025, month: 10, day: 8))
        #expect(statistics.lastObservationDay == DateComponents(year: 2026, month: 11, day: 10))
        #expect(statistics.days.count == 1)
        #expect(statistics.weeks.isEmpty)
        #expect(statistics.months.isEmpty)
        #expect(statistics.years.isEmpty)
        #expect(statistics.allTime == nil)

        let day = try #require(statistics.days.first)
        #expect(day.date == DateComponents(year: 2025, month: 10, day: 8))
        #expect(day.pressure == 1007.1)
        #expect(day.pressureHigh == 1009.0)
        #expect(day.temperature == 42.5)
        #expect(day.temperatureLow == 21.0)
        #expect(day.relativeHumidityHigh == 22)
        #expect(day.illuminanceHigh == 100_000)
        #expect(day.uvIndex == 8.88)
        #expect(day.solarRadiationHigh == 900)
        #expect(day.windAverage == 0.1)
        #expect(day.windGust == 1.1)
        #expect(day.windDirection == 122)
        #expect(day.windSampleInterval == 60)
        #expect(day.lightningStrikeCount == 2)
        #expect(day.lightningStrikeAverageDistance == 8.5)
        #expect(day.recordCount == 1440)
        #expect(day.batteryVoltage == 3.2)
        #expect(day.precipitation == 0.02)
        #expect(day.precipitationFinal == 0.03)
        #expect(day.precipitationMinutes == 3)
        #expect(day.precipitationMinutesFinal == 4)
        #expect(day.precipitationType == .rain)
        #expect(day.precipitationAnalysisType == .rainCheckHidden)
    }

    @Test("The week, month, year and all-time rows map too")
    func aggregates() throws {
        let payload = """
            {
              "station_id": 100001,
              "stats_week": [["2026-10-05", 994.8, 1001.5, 983.9]],
              "stats_month": [["2026-10-01", 1001.9, 1009.7, 983.9]],
              "stats_year": [["2026-01-01", 1003.0, 1010.1, 983.9]],
              "stats_alltime": ["2026-11-22", 1003.0, 1010.1, 983.9],
              "stats_week_time": [["2026-10-05", null, "2026-10-11", "2026-10-11"]],
              "stats_month_time": [["2026-10-01", null, "2026-10-17"]],
              "stats_year_time": [["2026-01-01", null, "2026-11-02"]],
              "stats_alltime_time": ["2026-11-22", null, "2026-11-02"]
            }
            """
        let response = try JSONDecoder().decode(StationStatsResponseDTO.self, from: Data(payload.utf8))
        let statistics = StationStatistics(dto: response)

        let week = try #require(statistics.weeks.first)
        #expect(week.date == DateComponents(year: 2026, month: 10, day: 5))
        #expect(week.pressure == 994.8)
        #expect(week.pressureHigh == 1001.5)

        #expect(statistics.months.count == 1)
        #expect(statistics.years.count == 1)

        let allTime = try #require(statistics.allTime)
        #expect(allTime.date == DateComponents(year: 2026, month: 11, day: 22))
        #expect(allTime.pressure == 1003.0)

        let weekTimes = try #require(statistics.weekTimes.first)
        #expect(weekTimes.periodStart == DateComponents(year: 2026, month: 10, day: 5))
        #expect(weekTimes.columns.count == 3)
        #expect(weekTimes.columns[0] == nil)
        #expect(weekTimes.columns[1] == DateComponents(year: 2026, month: 10, day: 11))

        #expect(statistics.monthTimes.count == 1)
        #expect(statistics.yearTimes.count == 1)
        #expect(
            statistics.allTimeTimes?.periodStart
                == DateComponents(year: 2026, month: 11, day: 22)
        )
    }

    @Test("The spelling from the docs works too")
    func specSpelling() throws {
        let payload = """
            {"station_id": 1, "first_ob_local_day": "2026-11-10", "last_ob_local_day": "2026-11-11"}
            """
        let response = try JSONDecoder().decode(StationStatsResponseDTO.self, from: Data(payload.utf8))
        let statistics = StationStatistics(dto: response)

        #expect(statistics.days.isEmpty)
        #expect(statistics.firstObservationDay == DateComponents(year: 2026, month: 11, day: 10))
        #expect(statistics.lastObservationDay == DateComponents(year: 2026, month: 11, day: 11))
    }

    @Test("A row without a date is dropped")
    func datelessRow() throws {
        let payload = #"{"station_id": 1, "stats_day": [[1007.1, 994.5]]}"#
        let response = try JSONDecoder().decode(StationStatsResponseDTO.self, from: Data(payload.utf8))

        #expect(StationStatistics(dto: response).days.isEmpty)
    }

    @Test("A first/last day that isn't a date is nil")
    func malformedDay() {
        #expect(StationStatistics.localDay(from: "2026-11") == nil)
        #expect(StationStatistics.localDay(from: "not a date") == nil)
    }
}
