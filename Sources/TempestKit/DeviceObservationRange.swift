//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// What part of a device's history to ask for.
public enum DeviceObservationRange: Hashable, Sendable {

    /// The most recent row
    case latest

    /// A whole UTC day. 0 is today, 1 is yesterday.
    case day(offset: Int)

    /// A range of up to five days at one-minute resolution
    case range(ClosedRange<Date>)

    /// The longest range the endpoint returns at one-minute resolution.
    public static let maxSpan: TimeInterval = 5 * 86_400

    /// Splits a longer range into windows the endpoint will accept.
    ///
    /// - Parameter range: The range you want.
    /// - Returns: Back-to-back ranges no longer than `maxSpan`.
    public static func windows(for range: ClosedRange<Date>) -> [ClosedRange<Date>] {
        var windows: [ClosedRange<Date>] = []
        var start = range.lowerBound

        while start < range.upperBound {
            let end = min(start.addingTimeInterval(maxSpan), range.upperBound)
            windows.append(start...end)
            start = end.addingTimeInterval(1)
        }

        return windows.isEmpty ? [range] : windows
    }

    func queryItems() throws(TempestError) -> [URLQueryItem] {
        switch self {
        case .latest:
            return []
        case .day(let offset):
            guard offset >= 0 else { throw .invalidRequest }
            return [URLQueryItem(name: "day_offset", value: "\(offset)")]
        case .range(let range):
            guard range.upperBound.timeIntervalSince(range.lowerBound) <= Self.maxSpan else {
                throw .rangeTooLong(maxSpan: Self.maxSpan)
            }
            return [
                URLQueryItem(name: "time_start", value: "\(Int(range.lowerBound.timeIntervalSince1970))"),
                URLQueryItem(name: "time_end", value: "\(Int(range.upperBound.timeIntervalSince1970))"),
            ]
        }
    }
}
