# What the API Covers

TempestKit covers all seven Home API endpoints, the WebSocket feed and the local broadcasts. The paid TempestOne endpoints are out of reach with a personal token.

The Home API is read-only. Every endpoint is a GET, so there's nothing for changing station settings, sharing or devices.

## Stations

| Endpoint | TempestKit |
| --- | --- |
| `GET /stations` | `stations(token:)` returns the array; `stationSet(token:)` also has the API's status |
| `GET /stations/{station_id}` | `station(_:token:)`, or nil when the response has no station |

## Readings

| Endpoint | TempestKit |
| --- | --- |
| `GET /observations/stn/{station_id}` | `latestObservation(station:token:)`, `latestStationObservations(station:token:)`, and `observations(station:range:bucket:token:)` |
| `GET /observations/stn/{station_id}` over a range | `stationObservations(station:range:bucket:token:)` keeps the source, units and status |
| `GET /observations/device/{device_id}` | `deviceObservations(device:range:token:)` and `deviceObservationsCSV(device:range:token:)` |
| `GET /observations/station/{station_id}` | `conditions(station:token:)`, with the API's calculated values |
| `GET /stats/station/{station_id}` | `statistics(station:token:)`, one row per day plus weekly, monthly, yearly and all-time rows |
| `GET /better_forecast` | `forecast(station:units:token:)`, with current conditions, hours and days |

The station observations endpoint documents `units_*` and `obs_fields`, but the API ignores both, so the client doesn't send them. The device endpoint's `day_offset`, `time_start`, `time_end` and `format=csv` are available through `DeviceObservationRange` and the CSV method.

## Live readings

The two live products are separate packages:

- `TempestKitUDP` reads every message the hub broadcasts: Tempest, Air and Sky observations, rapid wind, lightning strikes, rain starts, and device and hub status.
- `TempestKitWebSocket` reads the feed WeatherFlow pushes: device observations, rapid wind, lightning strikes, rain starts, and the lightning map feed when your account has it.

Neither one covers history. Use the REST endpoints for that.

## What needs TempestOne

A personal token only sees its owner's stations, and only for personal use. That's what WeatherFlow's [Remote Data Access Policy](https://weatherflow.github.io/Tempest/api/remote-developer-policy.html) says. Anyone else's stations, commercial use, or anything below needs a paid TempestOne account:

| Endpoint or product | What it returns |
| --- | --- |
| `/metadata/network/stations` | Info about stations on the network |
| `/observations/network/stations` | Current readings from network stations |
| `/diagnostics/{station_id}` | Station health: online, firmware, signal, uptime |
| `/lightning` | Strikes from the last hour by radius or box, also sold as the lightning add-on |
| `/better_forecast` with `lat`/`lon` | A forecast for a location instead of a station |
| TempestOne Extended | Model grids, radar and satellite tiles, bay currents and tides |

There's no map or tile endpoint in the free API. The only location data it has is the station's coordinates and the forecast's.

## What stays out of the package

- **OAuth sign-in.** It needs a sign-in screen, a redirect, a secret or verifier, and somewhere to keep the token. Do that in your app and pass TempestKit the token you get.
- **Calculating values.** `conditions(station:token:)` already has WeatherFlow's numbers. A second calculation would only give a second answer.
- **Writing.** The Home API has no write endpoints.
