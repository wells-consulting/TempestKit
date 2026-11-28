//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Which RainCheck correction the API applied to a rain total.
///
/// We don't use `.none` for zero because these values are optional, and
/// `.none` would read as `Optional.none` in a lot of code.
public enum PrecipitationAnalysis: Hashable, Sendable {

    /// No correction was applied
    case noAnalysis

    /// RainCheck was applied and the owner's settings show it
    case rainCheckShown

    /// RainCheck was applied and the owner's settings hide it
    case rainCheckHidden

    /// A code we don't know yet
    case other(Int)

    /// - Parameter code: The number the API sent.
    public init(code: Int) {
        switch code {
        case 0: self = .noAnalysis
        case 1: self = .rainCheckShown
        case 2: self = .rainCheckHidden
        default: self = .other(code)
        }
    }
}
