//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation
import Testing

@testable import TempestKit

struct WindowTests {

    private static let day: TimeInterval = 86_400

    private static let start = Date(timeIntervalSince1970: 1_791_460_800)

    @Test("A range within a day is one window")
    func singleWindow() {
        let end = Self.start.addingTimeInterval(Self.day)
        let windows = ObservationBucket.oneMinute.windows(for: Self.start...end)
        #expect(windows == [Self.start...end])
    }

    @Test("An hour is still one window")
    func hourWindow() {
        let end = Self.start.addingTimeInterval(3_600)
        #expect(ObservationBucket.oneMinute.windows(for: Self.start...end).count == 1)
    }

    @Test("A zero-width range is one window")
    func zeroWidth() {
        #expect(ObservationBucket.oneMinute.windows(for: Self.start...Self.start) == [Self.start...Self.start])
    }

    @Test("A three day range is three back-to-back windows")
    func threeDays() {
        let end = Self.start.addingTimeInterval(Self.day * 3)
        let windows = ObservationBucket.oneMinute.windows(for: Self.start...end)

        #expect(windows.count == 3)
        #expect(windows[0] == Self.start...Self.start.addingTimeInterval(Self.day))
        #expect(windows[2].upperBound == end)
        for (earlier, later) in zip(windows, windows.dropFirst()) {
            #expect(earlier.upperBound.addingTimeInterval(1) == later.lowerBound)
        }
    }
}
