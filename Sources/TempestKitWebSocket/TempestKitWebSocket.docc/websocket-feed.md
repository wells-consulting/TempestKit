# The WebSocket Feed

One connection, device readings as they happen.

## Open the stream

`TempestWebSocket` takes a token, or a developer API key with `init(apiKey:)`. Ask for the devices you want and read the events:

```swift
import TempestKitWebSocket

let socket = TempestWebSocket(token: myToken)

for try await event in try await socket.listen(to: station.devices.map(\.id)) {
    switch event {
    case .observation(let deviceID, let reading):
        print(deviceID, reading.airTemperature ?? 0)
    case .rapidWind(let deviceID, _, let speed, _):
        print(deviceID, speed)
    case .lightningStrike(let deviceID, _, let distance, _):
        print(deviceID, distance)
    case .rainStart(let deviceID):
        print(deviceID)
    case .geoStrike(_, let latitude, let longitude, _, _):
        print(latitude, longitude)
    case .acknowledged:
        break
    }
}
```

Pass `rapidWind: true` to also get the three-second wind samples. Pass `lightning:` to watch a box for strikes on the same connection:

```swift
let box = GeoBox(south: 37.0, west: -123.0, north: 38.0, east: -122.0)
let request = LightningRequest(bounds: box)

for try await event in try await socket.listen(
    to: [device.id],
    rapidWind: true,
    lightning: request
) {
    if case .geoStrike(_, let latitude, let longitude, _, _) = event {
        print(latitude, longitude)
    }
}
```

The lightning feed may need a token with WeatherFlow's lightning add-on.

## What arrives

| Event | What it is |
| --- | --- |
| `.acknowledged` | The server accepted a `listen` request |
| `.observation` | A device reading: Tempest, Air or Sky |
| `.rapidWind` | A three-second wind sample |
| `.lightningStrike` | A strike from the station's own sensor |
| `.rainStart` | The rain sensor saw the first drops |
| `.geoStrike` | A strike in the box you asked to watch |

Device readings are `DeviceObservation`, the same type `/observations/device` returns. A Tempest, an Air and a Sky all come through as one.

## Rules of the connection

- **One per app.** A second `listen(to:...)` throws `TempestError.alreadyConnected`.
- **Listen to a device.** The server drops a connection after ten minutes with nothing to say, so listen to at least one device.
- **No reconnect.** When the stream finishes, make a new client. `close()` ends the connection now.
- **One stream.** `listen(to:...)` returns one event stream. Keep iterating it, or the socket goes away.
- **Stop a device with `stopListening(to:)`.** The connection stays open for the other devices.

The stream doesn't carry history. For anything before now, use the REST calls.
