//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Foundation

/// The hourly and daily parts of a `better_forecast` response. Either one can
/// be missing.
struct BetterForecastBlockDTO: Decodable, Sendable {

    let hourly: [BetterForecastHourDTO]?
    let daily: [BetterForecastDayDTO]?

    private enum CodingKeys: String, CodingKey {
        case hourly
        case daily
    }
}
