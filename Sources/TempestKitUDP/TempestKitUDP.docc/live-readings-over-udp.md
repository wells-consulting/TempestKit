# Live Readings over UDP

Read the messages a hub broadcasts on port 50222.

## Open the stream

`TempestUDP` needs the station's ID and the hub's serial number. The station's `hub` device has the serial:

```swift
import TempestKitUDP

guard let hub = station.hub?.serialNumber else { return }
let udp = TempestUDP(station: station.id, hubSerialNumber: hub)

for try await broadcast in try udp.listen() {
    switch broadcast {
    case .observation(_, let reading):
        print(reading.airTemperature)
    case .airObservation(_, let reading):
        print(reading.airTemperature ?? 0)
    case .skyObservation(_, let reading):
        print(reading.windAverage ?? 0)
    case .rapidWind(_, _, _, let speed, let direction):
        print(speed, direction)
    case .lightningStrike(_, _, _, let distance, _):
        print(distance)
    case .rainStart(_, _, let date):
        print(date)
    case .deviceStatus(let status):
        print(status.sensorStatus)
    case .hubStatus(let status):
        print(status.resetFlags)
    }
}
```

The stream starts when you iterate it and stops when the task is canceled.

## What arrives

| Message | Device | How often |
| --- | --- | --- |
| Tempest observation | Tempest | About once a minute |
| Air observation | Air | About once a minute |
| Sky observation | Sky | About once a minute |
| Rapid wind | Tempest, Sky | About every 3 seconds |
| Lightning strike | Tempest, Air | When a strike happens |
| Rain start | Tempest, Sky | When rain starts |
| Device status | Each sensor | About once a minute |
| Hub status | Hub | About once a minute |

A Tempest observation is the same `StationObservation` the REST calls return, except the broadcast has no sea level pressure. An Air or Sky reading is a `DeviceObservation`.

## Before it works

- **One listener.** Only one listener can have the port at a time. If something else already has it, the stream finishes with `TempestError.listeningFailed`.
- **Local network access.** The system asks the first time. Nothing arrives if it's denied.
- **Multicast on iOS and visionOS.** The app needs the multicast entitlement, which Apple has to grant. macOS doesn't need it.
- **The same network.** The hub broadcasts on the local network, so a remote device won't see it.

There's no token and nothing to configure. It's receive only.
