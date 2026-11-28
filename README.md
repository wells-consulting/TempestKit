# TempestKit

A Swift package for the WeatherFlow Tempest weather station: the REST API, the WebSocket feed and the local UDP broadcasts.

> **Unofficial.** This isn't made by, endorsed by, or supported by WeatherFlow. "Tempest" is their product name, used here so you know what the package talks to. The API docs are at <https://apidocs.tempestwx.com>.

[![Documentation](https://img.shields.io/badge/documentation-DocC-blue)](https://swiftpackageindex.com/wells-consulting/tempestkit/documentation/tempestkit)

Swift 6.2, strict concurrency, no package dependencies.

## Platforms

| Platform    | Status    |
| ----------- | --------- |
| macOS 26+   | Supported |
| iOS 26+     | Supported |
| tvOS 26+    | Supported |
| watchOS 26+ | Supported |
| Linux       | Supported |

The REST client only needs Foundation and `URLSession`. `TempestKitUDP` adds `Network.framework`, so Linux gets the REST client only; receiving broadcasts has only been tried on macOS so far. `TempestKitWebSocket` builds everywhere, but on Linux it needs a libcurl built with WebSocket support.

## Install

```swift
dependencies: [
    .package(url: "https://github.com/wells-consulting/TempestKit.git", .upToNextMajor(from: "1.0.0")),
]
```

Add the product you need to your target:

```swift
.product(name: "TempestKit", package: "TempestKit")
```

## Usage

Pass a personal access token or an OAuth token with every call. The client never stores it.

```swift
import TempestKit

let client = TempestClient()

for station in try await client.stations(token: myToken) {
    print(station.name, station.id)
}

let now = try await client.latestObservation(station: station.id, token: myToken)
print(now.airTemperature, now.windAverage ?? 0)
```

The other two products are separate packages:

```swift
import TempestKitUDP

if let hub = station.hub?.serialNumber {
    let udp = TempestUDP(station: station.id, hubSerialNumber: hub)
    for try await broadcast in try udp.listen() {
        print(broadcast)
    }
}
```

```swift
import TempestKitWebSocket

let socket = TempestWebSocket(token: myToken)
for try await event in try await socket.listen(to: station.devices.map(\.id)) {
    print(event)
}
```

## Documentation

The DocC guides cover tokens, ranges and buckets, forecast units, errors, the models and the places where the API and the docs disagree.

- [TempestKit](https://swiftpackageindex.com/wells-consulting/tempestkit/documentation/tempestkit)
- [TempestKitUDP](https://swiftpackageindex.com/wells-consulting/tempestkit/documentation/tempestkitudp)
- [TempestKitWebSocket](https://swiftpackageindex.com/wells-consulting/tempestkit/documentation/tempestkitwebsocket)
- [Getting Started](https://swiftpackageindex.com/wells-consulting/tempestkit/documentation/tempestkit/getting-started)

## What's covered

All seven Home API endpoints, all eight UDP messages and the WebSocket feed. The API is read-only, and a personal token only sees its owner's stations. Network stations, diagnostics, lightning maps and location forecasts need a paid TempestOne account.

## What the client doesn't do

It doesn't wait between requests, cache, retry or log. Those depend on your app. Failures are `TempestError` values, and none of them include the token.

## Testing

The tests use saved API responses, saved broadcasts and saved WebSocket messages, so you don't need a network connection or a token. Set `TEMPEST_LIVE_TOKEN` to run the live REST and WebSocket checks; they're skipped without it.

## AI disclosure

Some of this code was written with AI agents. [AI-DISCLOSURE.md](AI-DISCLOSURE.md) covers what that means here.

## License

MIT. See `LICENSE`.
