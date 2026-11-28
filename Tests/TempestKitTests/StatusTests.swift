//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Testing

@testable import TempestKit

struct StatusTests {

    @Test("Sensor flags combine and keep unknown bits")
    func sensorStatus() {
        let flags: SensorStatus = [
            .lightningFailed,
            .lightningNoise,
            .powerBoosterShorePower,
        ]

        #expect(flags.contains(.lightningFailed))
        #expect(flags.contains(.lightningNoise))
        #expect(flags.contains(.pressureFailed) == false)
        #expect(flags.rawValue == 1 | 2 | 1 << 16)

        let future = SensorStatus(rawValue: 1 << 20)
        #expect(future.rawValue == 1 << 20)
        #expect(future.isEmpty == false)
    }

    @Test("Reset flag names map")
    func resetFlags() {
        let flags = ResetFlags(names: "BOR,PIN,POR")

        #expect(flags.contains(.brownout))
        #expect(flags.contains(.pin))
        #expect(flags.contains(.power))
        #expect(flags.contains(.software) == false)
    }

    @Test("An unknown reset flag is ignored")
    func unknownResetFlag() {
        let flags = ResetFlags(names: "BOR,BRAND_NEW")
        #expect(flags == [.brownout])
    }

    @Test("Reset flags handle spaces and an empty string")
    func resetFlagSpacing() {
        #expect(ResetFlags(names: " BOR , PIN ").contains(.pin))
        #expect(ResetFlags(names: "").isEmpty)
    }

    @Test("Each radio state code maps")
    func radioStates() {
        #expect(RadioState(code: 0) == .off)
        #expect(RadioState(code: 1) == .on)
        #expect(RadioState(code: 3) == .active)
        #expect(RadioState(code: 7) == .bleConnected)
        #expect(RadioState(code: 99) == .other(99))
    }
}
