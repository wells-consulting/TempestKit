//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// A `/stats/station/{id}` response, exactly as the API sends it.
///
/// The docs don't mention it, but each `stats_day` row starts with its date
/// as a string, then the 33 numbers. So a row is a mix of types.
///
/// The API sends `first_ob_day_local`, but the docs say `first_ob_local_day`.
/// We check both in case one of them gets fixed.
struct StationStatsResponseDTO: Decodable, Sendable {

    let status: ResponseStatusDTO?
    let type: String?
    let stationID: Int
    let firstObservationLocalDay: String?
    let lastObservationLocalDay: String?
    let days: [StationStatsDayDTO]
    let weeks: [StationStatsDayDTO]
    let months: [StationStatsDayDTO]
    let years: [StationStatsDayDTO]
    let allTime: StationStatsDayDTO?
    let weeksTimes: [StationStatsTimeDTO]
    let monthsTimes: [StationStatsTimeDTO]
    let yearsTimes: [StationStatsTimeDTO]
    let allTimeTimes: StationStatsTimeDTO?

    private enum CodingKeys: String, CodingKey {
        case status
        case type
        case stationID = "station_id"
        case firstObservationLocalDay = "first_ob_day_local"
        case lastObservationLocalDay = "last_ob_day_local"
        case specFirstObservationLocalDay = "first_ob_local_day"
        case specLastObservationLocalDay = "last_ob_local_day"
        case days = "stats_day"
        case weeks = "stats_week"
        case months = "stats_month"
        case years = "stats_year"
        case allTime = "stats_alltime"
        case weeksTimes = "stats_week_time"
        case monthsTimes = "stats_month_time"
        case yearsTimes = "stats_year_time"
        case allTimeTimes = "stats_alltime_time"
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(ResponseStatusDTO.self, forKey: .status)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        stationID = try container.decode(Int.self, forKey: .stationID)
        firstObservationLocalDay =
            try container.decodeIfPresent(String.self, forKey: .firstObservationLocalDay)
            ?? container.decodeIfPresent(String.self, forKey: .specFirstObservationLocalDay)
        lastObservationLocalDay =
            try container.decodeIfPresent(String.self, forKey: .lastObservationLocalDay)
            ?? container.decodeIfPresent(String.self, forKey: .specLastObservationLocalDay)
        days = try container.decodeIfPresent([StationStatsDayDTO].self, forKey: .days) ?? []
        weeks = try container.decodeIfPresent([StationStatsDayDTO].self, forKey: .weeks) ?? []
        months = try container.decodeIfPresent([StationStatsDayDTO].self, forKey: .months) ?? []
        years = try container.decodeIfPresent([StationStatsDayDTO].self, forKey: .years) ?? []
        allTime = try container.decodeIfPresent(StationStatsDayDTO.self, forKey: .allTime)
        weeksTimes = try container.decodeIfPresent([StationStatsTimeDTO].self, forKey: .weeksTimes) ?? []
        monthsTimes = try container.decodeIfPresent([StationStatsTimeDTO].self, forKey: .monthsTimes) ?? []
        yearsTimes = try container.decodeIfPresent([StationStatsTimeDTO].self, forKey: .yearsTimes) ?? []
        allTimeTimes = try container.decodeIfPresent(StationStatsTimeDTO.self, forKey: .allTimeTimes)
    }
}

/// One `stats_day` row: the date, then 33 numbers
struct StationStatsDayDTO: Decodable, Sendable {

    let date: String?
    let values: [Double?]

    init(from decoder: any Decoder) throws {
        let raw = try decoder.singleValueContainer().decode([StatsValueDTO].self)
        guard case .text(let text)? = raw.first else {
            date = nil
            values = raw.map(\.number)
            return
        }
        date = text
        values = raw.dropFirst().map(\.number)
    }
}

/// One `stats_*_time` row: text dates and nulls.
struct StationStatsTimeDTO: Decodable, Sendable {

    let values: [StatsValueDTO]

    init(from decoder: any Decoder) throws {
        values = try decoder.singleValueContainer().decode([StatsValueDTO].self)
    }
}

/// One value in a stats row. The first one is the date (text). The rest are
/// numbers, or null if a sensor didn't report.
enum StatsValueDTO: Decodable {

    case text(String)
    case number(Double?)

    var number: Double? {
        guard case .number(let value) = self else { return nil }
        return value
    }

    var text: String? {
        guard case .text(let value) = self else { return nil }
        return value
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .number(nil)
            return
        }

        do {
            self = .text(try container.decode(String.self))
        } catch {
            self = .number(try container.decode(Double.self))
        }
    }
}
