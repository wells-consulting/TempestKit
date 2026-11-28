//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct DeviceObservationRangeTests {

    private static let start = Date(timeIntervalSince1970: 1_791_460_800)

    @Test("Latest sends no query")
    func latest() throws {
        #expect(try DeviceObservationRange.latest.queryItems().isEmpty)
    }

    @Test("A day offset is one query item")
    func day() throws {
        let items = try DeviceObservationRange.day(offset: 1).queryItems()
        #expect(items == [URLQueryItem(name: "day_offset", value: "1")])
    }

    @Test("A negative day offset is refused")
    func negativeDay() {
        #expect(throws: TempestError.invalidRequest) {
            try DeviceObservationRange.day(offset: -1).queryItems()
        }
    }

    @Test("A range sends its start and end")
    func range() throws {
        let end = Self.start.addingTimeInterval(86_400)
        let items = try DeviceObservationRange.range(Self.start...end).queryItems()

        #expect(items == [
            URLQueryItem(name: "time_start", value: "1791460800"),
            URLQueryItem(name: "time_end", value: "1791547200"),
        ])
    }

    @Test("A range longer than five days is refused")
    func longRange() {
        let end = Self.start.addingTimeInterval(6 * 86_400)

        #expect(throws: TempestError.rangeTooLong(maxSpan: DeviceObservationRange.maxSpan)) {
            try DeviceObservationRange.range(Self.start...end).queryItems()
        }
    }

    @Test("A long range splits into five-day windows")
    func windows() {
        let end = Self.start.addingTimeInterval(12 * 86_400)
        let windows = DeviceObservationRange.windows(for: Self.start...end)

        #expect(windows.count == 3)
        #expect(windows[0].lowerBound == Self.start)
        #expect(windows[0].upperBound == Self.start.addingTimeInterval(5 * 86_400))
        #expect(windows[1].lowerBound == Self.start.addingTimeInterval(5 * 86_400 + 1))
        #expect(windows.last?.upperBound == end)
    }

    @Test("A zero-width range is one window")
    func zeroWidth() {
        let range = Self.start...Self.start
        #expect(DeviceObservationRange.windows(for: range) == [range])
    }
}
