//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// Which way the barometer is going
public enum PressureTrend: String, CaseIterable, Hashable, Sendable {

    case falling
    case steady
    case rising

    /// The API actually sends "unknown" sometimes. That's different from
    /// sending nothing, so we keep it.
    case unknown
}
