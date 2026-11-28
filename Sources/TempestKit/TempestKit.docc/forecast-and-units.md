# Forecast and Units

Ask for the units you want, and the forecast comes back in them.

`forecast(station:units:token:)` returns current conditions, the hourly forecast and the daily forecast in one response. If a screen shows both the hours and the days, ask once and use the same value.

```swift
let forecast = try await client.forecast(
    station: station.id,
    units: .imperial,
    token: myToken
)

print(forecast.currentConditions?.feelsLike ?? 0)
for hour in forecast.hours.prefix(6) {
    print(hour.timestamp, hour.airTemperature ?? 0)
}
```

## The units you can ask for

`Units` has five parts, and `Units()` is the API's default:

| Part | Default | Other values |
| --- | --- | --- |
| Temperature | °C | °F |
| Wind | m/s | mph, kph, knots, Beaufort, feet per minute |
| Pressure | MB | inHg, mmHg, hPa |
| Precipitation | mm | cm, inches |
| Distance | km | miles |

`Units.metric` and `Units.imperial` are shortcuts for the two common sets. `Units.imperial` is °F, mph, inHg, inches and miles.

```swift
let us = Units.imperial
let custom = Units(temperature: .celsius, wind: .knots)
```

`TempestForecast.responseUnits` says what the response actually used.

## The rest of the package is metric

Only the forecast takes units. `latestObservation`, `conditions`, `statistics` and the device readings always come back metric, whatever the station owner picked in the Tempest app. That choice is a display setting, not a change in the data.

`StationConditions.displayUnits` and `DisplayUnits` tell you what the owner sees, in case you want to format values the same way:

```swift
let conditions = try await client.conditions(station: station.id, token: myToken)
if conditions.displayUnits?.temperature == .fahrenheit {
    // Format the metric value as °F for this owner.
}
```

## A forecast is not a measurement

The forecast's current conditions are the API's own summary for the station, not the latest observation row. Use `latestObservation(station:token:)` or `conditions(station:token:)` when you need the station's reading.
