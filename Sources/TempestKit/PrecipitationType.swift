//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// What fell during the reporting interval.
///
/// The API sends a number. We don't use `.none` for zero because these values
/// are optional, and `.none` would read as `Optional.none` in a lot of code.
public enum PrecipitationType: Hashable, Sendable {

    /// Nothing fell
    case noPrecipitation

    case rain
    case hail

    /// The API calls this "rain + hail" and marks it experimental
    case rainAndHail

    /// A code we don't know yet
    case other(Int)

    /// - Parameter code: The number the API sent.
    public init(code: Int) {
        switch code {
        case 0: self = .noPrecipitation
        case 1: self = .rain
        case 2: self = .hail
        case 3: self = .rainAndHail
        default: self = .other(code)
        }
    }
}
