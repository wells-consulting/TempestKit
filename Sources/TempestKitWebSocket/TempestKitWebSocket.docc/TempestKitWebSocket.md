# ``TempestKitWebSocket``

The station's live feed over one connection.

> Important: TempestKit isn't made by, endorsed by or supported by WeatherFlow. "Tempest" is their product name, used here so you know what the package talks to.

## Overview

`TempestWebSocket` opens a WebSocket to WeatherFlow and pushes device readings as they happen. Create it with a token, or with a developer API key:

```swift
let socket = TempestWebSocket(token: myToken)

for try await event in try await socket.listen(to: station.devices.map(\.id)) {
    switch event {
    case .observation(let deviceID, let reading):
        print(deviceID, reading.airTemperature ?? 0)
    case .rapidWind(let deviceID, _, let speed, _):
        print(deviceID, speed)
    default:
        break
    }
}
```

Open one connection per app and listen to at least one device. The server drops a connection after ten minutes with nothing to say. There's no automatic reconnect, so make a new client when the stream ends.

The feed sends device readings, not station readings. A Tempest, an Air and a Sky all come through as `DeviceObservation`. Pass `lightning:` to watch a box for strikes on the same connection; those arrive as `.geoStrike`.

## Topics

### Essentials

- <doc:websocket-feed>
- ``TempestWebSocket``
- ``TempestWebSocketEvent``

### Lightning

- ``LightningRequest``
- ``GeoBox``
- ``StrikeType``
