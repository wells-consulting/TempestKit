//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// How many minutes each observation row covers.
///
/// The bigger the bucket, the more history you can ask for in one request.
/// For more than that, split the range with `windows(for:)`.
///
/// Anything other than `.oneMinute` is a summary the API makes for us. It
/// doesn't say how (average? max?), and we haven't figured it out, so don't
/// treat those rows as real measurements.
public enum ObservationBucket: Int, CaseIterable, Hashable, Sendable {

    /// The station's own once-a-minute readings. This is the default.
    case oneMinute = 1

    case fiveMinutes = 5

    case thirtyMinutes = 30

    case threeHours = 180

    case oneDay = 1440

    /// The longest range one request can cover at this bucket size
    public var maxSpan: TimeInterval {
        switch self {
        case .oneMinute:
            86_400 // 1 day
        case .fiveMinutes:
            5 * 86_400 // 5 days
        case .thirtyMinutes:
            30 * 86_400 // 30 days
        case .threeHours:
            180 * 86_400 // 180 days
        case .oneDay:
            4 * 366 * 86_400 // 4 years
        }
    }

    /// Splits `range` into back-to-back windows no longer than `maxSpan`, so
    /// each one fits in one request. A short range (even one with zero
    /// length) is just one window.
    public func windows(for range: ClosedRange<Date>) -> [ClosedRange<Date>] {
        var windows: [ClosedRange<Date>] = []
        var start = range.lowerBound

        while start < range.upperBound {
            let end = min(start.addingTimeInterval(maxSpan), range.upperBound)
            windows.append(start...end)
            start = end.addingTimeInterval(1)
        }

        return windows.isEmpty ? [range] : windows
    }
}
