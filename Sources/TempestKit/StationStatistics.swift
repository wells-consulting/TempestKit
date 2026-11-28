//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Summaries for a station's whole history: one row per day, plus weekly,
/// monthly, yearly and all-time rows.
///
/// Dates are `DateComponents` instead of `Date` because the API sends a plain
/// local day like `2022-03-14` with no time zone.
public struct StationStatistics: Hashable, Sendable {

    /// The API's status object.
    public let status: ResponseStatus?
    /// The API's record type, usually `station_stats`
    public let type: String?
    /// The station the summaries belong to.
    public let stationID: WeatherStation.ID

    /// The local day of the station's first observation
    public let firstObservationDay: DateComponents?

    /// The local day of its most recent observation
    public let lastObservationDay: DateComponents?

    /// Oldest first
    public let days: [Day]

    /// One row per week, oldest first
    public let weeks: [Day]

    /// One row per month, oldest first
    public let months: [Day]

    /// One row per year, oldest first
    public let years: [Day]

    /// The whole history as one row
    public let allTime: Day?

    /// The `stats_week_time` rows
    public let weekTimes: [Times]

    /// The `stats_month_time` rows
    public let monthTimes: [Times]

    /// The `stats_year_time` rows
    public let yearTimes: [Times]

    /// The `stats_alltime_time` row
    public let allTimeTimes: Times?

    /// Creates a statistics value from the values it describes.
    ///
    /// The client builds these from the JSON, so most apps don't call this
    /// directly.
    ///
    /// - Parameters:
    ///   - status: The API's status object.
    ///   - type: The API's record type.
    ///   - stationID: The station the summaries belong to.
    ///   - firstObservationDay: The local day of the first observation.
    ///   - lastObservationDay: The local day of the most recent observation.
    ///   - days: One row per day, oldest first.
    ///   - weeks: One row per week, oldest first.
    ///   - months: One row per month, oldest first.
    ///   - years: One row per year, oldest first.
    ///   - allTime: The whole history as one row.
    ///   - weekTimes: The `stats_week_time` rows.
    ///   - monthTimes: The `stats_month_time` rows.
    ///   - yearTimes: The `stats_year_time` rows.
    ///   - allTimeTimes: The `stats_alltime_time` row.
    public init(
        status: ResponseStatus? = nil,
        type: String? = nil,
        stationID: WeatherStation.ID,
        firstObservationDay: DateComponents?,
        lastObservationDay: DateComponents?,
        days: [Day],
        weeks: [Day] = [],
        months: [Day] = [],
        years: [Day] = [],
        allTime: Day? = nil,
        weekTimes: [Times] = [],
        monthTimes: [Times] = [],
        yearTimes: [Times] = [],
        allTimeTimes: Times? = nil
    ) {
        self.status = status
        self.type = type
        self.stationID = stationID
        self.firstObservationDay = firstObservationDay
        self.lastObservationDay = lastObservationDay
        self.days = days
        self.weeks = weeks
        self.months = months
        self.years = years
        self.allTime = allTime
        self.weekTimes = weekTimes
        self.monthTimes = monthTimes
        self.yearTimes = yearTimes
        self.allTimeTimes = allTimeTimes
    }
}

extension StationStatistics {

    /// One `stats_*_time` row: when each value in the matching stats row
    /// happened.
    public struct Times: Hashable, Sendable {

        /// The period's first day
        public let periodStart: DateComponents?

        /// One date per stats column, in the same order as `Day`. A column
        /// that doesn't have a time, like an average or a count, is nil.
        public let columns: [DateComponents?]

        /// Creates a time row.
        ///
        /// The client builds these from the JSON, so most apps don't call this
        /// directly.
        ///
        /// - Parameters:
        ///   - periodStart: The period's first day.
        ///   - columns: One date per stats column, in `Day`'s order.
        public init(
            periodStart: DateComponents? = nil,
            columns: [DateComponents?] = []
        ) {
            self.periodStart = periodStart
            self.columns = columns
        }
    }
}
