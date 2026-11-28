//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The state of the hub's radio, from `radio_stats`.
public enum RadioState: Hashable, Sendable {

    case off
    case on
    case active
    case bleConnected

    /// A state we don't know yet
    case other(Int)

    /// Creates a state from the number the API sent.
    ///
    /// - Parameter code: The number the API sent.
    public init(code: Int) {
        switch code {
        case 0: self = .off
        case 1: self = .on
        case 3: self = .active
        case 7: self = .bleConnected
        default: self = .other(code)
        }
    }
}
