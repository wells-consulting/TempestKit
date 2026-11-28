# ``TempestKitUDP``

Read the station's broadcasts on the local network.

> Important: TempestKit isn't made by, endorsed by or supported by WeatherFlow. "Tempest" is their product name, used here so you know what the package talks to.

## Overview

`TempestUDP` listens on port 50222 for the messages a hub broadcasts. There's no token, no request and no history. It's receive only, and it only works on the same network as the hub.

One listener can have the port at a time. If something else already has it, the stream finishes with `TempestError.listeningFailed`. On iOS and visionOS the app needs the multicast entitlement, which Apple has to grant. macOS doesn't need it, but the system asks for local network access the first time, and nothing arrives if that's denied.

A Tempest broadcast is the same `StationObservation` the REST calls return, except it has no sea level pressure. An Air or Sky broadcast is a `DeviceObservation`.

## Topics

### Essentials

- <doc:live-readings-over-udp>
- ``TempestUDP``

### Messages

- ``TempestBroadcast``
