# Reading Live Data

The station sends readings two ways: the hub broadcasts them on your local network, and WeatherFlow pushes them over one WebSocket. Both are live, neither has history.

| | UDP | WebSocket |
| --- | --- | --- |
| Product | `TempestKitUDP` | `TempestKitWebSocket` |
| Token | None | A token or a developer API key |
| Network | The same local network as the hub | The internet |
| Range | The hub's broadcasts | Any device on the account |
| History | No | No |
| Setup | The local network permission, and the multicast entitlement on iOS | Open a connection and listen to at least one device |

## UDP

`TempestUDP` listens on port 50222 for everything the hub sends: a Tempest, Air or Sky observation about once a minute, a wind sample about every three seconds, device and hub status about once a minute, and strikes and rain starts when they happen.

It needs no token and no account. Only one listener can have the port at a time, and the app needs local network access. On iOS and visionOS the multicast entitlement is also required, and Apple has to grant it.

## WebSocket

`TempestWebSocket` opens one connection and asks for the devices you name. The readings are device readings, not station readings. The server drops a connection after ten minutes with nothing to say, so listen to at least one device.

There's no automatic reconnect. When the stream finishes, make a new client. One connection per app is enough.

## Which one to use

Use UDP when the app is on the same network as the hub and you want the fastest wind updates without a token. Use WebSocket when the app is remote, needs readings from devices on the account that the hub doesn't broadcast, or wants the lightning feed.

For history, use the REST calls. Neither live product keeps anything.
