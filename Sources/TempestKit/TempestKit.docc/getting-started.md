# Getting Started

Add TempestKit to a package, make a client and read a station.

> Important: TempestKit isn't made by, endorsed by or supported by WeatherFlow. "Tempest" is their product name, used here so you know what the package talks to.

## Add the package

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/wells-consulting/TempestKit.git", .upToNextMajor(from: "1.0.0")),
]
```

Then add the product to the target that needs it:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "TempestKit", package: "TempestKit")
    ]
)
```

## Get a token

A personal access token is the quickest way in. Sign in at [tempestwx.com](https://tempestwx.com), open Settings, then Data Authorizations, and create one. If your app has a sign-in screen, use OAuth instead and pass the token you get to the client.

The client doesn't store the token, so your app decides where it lives. Every call takes one:

```swift
import TempestKit

let client = TempestClient()

for station in try await client.stations(token: myToken) {
    print(station.name, station.id)
}
```

## Read a station

The station list returns a `WeatherStation` for each station the token can see. A station's newest reading comes from `latestObservation(station:token:)`:

```swift
let reading = try await client.latestObservation(station: station.id, token: myToken)
print(reading.airTemperature ?? 0, reading.windAverage ?? 0)
```

The values are in the units the API sends: °C, m/s, MB, lux, W/m², mm and km. Everything except the air temperature is optional, because a station only reports what its hardware has.

## Where to go next

- ``TempestClient`` has the rest of the REST calls, one request each.
- ``StationObservation`` and ``StationConditions`` describe the readings.
- ``ObservationBucket`` explains how to ask for a range of history.
- ``TempestError`` is what a failed call throws.

The live products are separate. Add `TempestKitUDP` for the hub's local broadcasts, or `TempestKitWebSocket` for the feed WeatherFlow pushes over one connection.
