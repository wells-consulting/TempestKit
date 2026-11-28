//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Testing

@testable import TempestKit

struct PrecipitationTests {

    @Test("Every precipitation code the API documents maps")
    func precipitationCodes() {
        #expect(PrecipitationType(code: 0) == .noPrecipitation)
        #expect(PrecipitationType(code: 1) == .rain)
        #expect(PrecipitationType(code: 2) == .hail)
        #expect(PrecipitationType(code: 3) == .rainAndHail)
    }

    @Test("A precipitation code we don't know is kept")
    func unknownPrecipitation() {
        #expect(PrecipitationType(code: 99) == .other(99))
    }

    @Test("Every RainCheck analysis code maps")
    func analysisCodes() {
        #expect(PrecipitationAnalysis(code: 0) == .noAnalysis)
        #expect(PrecipitationAnalysis(code: 1) == .rainCheckShown)
        #expect(PrecipitationAnalysis(code: 2) == .rainCheckHidden)
    }

    @Test("An analysis code we don't know is kept")
    func unknownAnalysis() {
        #expect(PrecipitationAnalysis(code: 99) == .other(99))
    }
}
