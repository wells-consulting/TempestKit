//
// TempestKit
// Copyright 2026 Wells Consulting. MIT licensed.
//

import Testing

@testable import TempestKit

struct ForecastTypeTests {

    @Test("A forecast icon we don't know keeps its name")
    func unknownIcon() {
        let icon = TempestForecast.Icon(rawValue: "brand-new-icon")
        #expect(icon.rawValue == "brand-new-icon")
        #expect(icon != .clearDay)
    }

    @Test("The chance icons use the spelling the API sends")
    func chanceIcons() {
        #expect(TempestForecast.Icon.possiblyRainyDay.rawValue == "possibly-rainy-day")
        #expect(TempestForecast.Icon.possiblyRainyNight.rawValue == "possibly-rainy-night")
        #expect(TempestForecast.Icon.possiblySnowDay.rawValue == "possibly-snow-day")
        #expect(TempestForecast.Icon.possiblySleetNight.rawValue == "possibly-sleet-night")
        #expect(TempestForecast.Icon.possiblyThunderstormDay.rawValue == "possibly-thunderstorm-day")
    }

    @Test("The forecast precipitation types have their API strings")
    func precipitationTypes() {
        #expect(TempestForecast.PrecipitationType.rain.rawValue == "rain")
        #expect(TempestForecast.PrecipitationType.snow.rawValue == "snow")
        #expect(TempestForecast.PrecipitationType.sleet.rawValue == "sleet")
        #expect(TempestForecast.PrecipitationType.storm.rawValue == "storm")
    }

    @Test("A precipitation icon we don't know keeps its name")
    func unknownPrecipitationIcon() {
        let icon = TempestForecast.PrecipitationIcon(rawValue: "chance-hail")
        #expect(icon.rawValue == "chance-hail")
        #expect(icon != .chanceRain)
    }

    @Test("The compass points use the API's abbreviations")
    func compassPoints() {
        #expect(CompassPoint.north.rawValue == "N")
        #expect(CompassPoint.northNortheast.rawValue == "NNE")
        #expect(CompassPoint.eastSoutheast.rawValue == "ESE")
        #expect(CompassPoint.westNorthwest.rawValue == "WNW")
        #expect(CompassPoint.northNorthwest.rawValue == "NNW")
    }
}
