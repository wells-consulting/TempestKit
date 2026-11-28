# Models

What each type holds, and the units you'll find inside.

Everything is metric: °C, m/s, MB, lux, W/m², mm and km. The forecast is the one exception, because it takes the units you ask for.

## Readings

- `StationObservation` is one row from the station: wind, pressure, temperature, humidity, light, UV, solar, rain, lightning and battery. Everything except the air temperature is optional, because a station only reports what its hardware has.
- `DeviceObservation` is one row from a single device, from `/observations/device`, the WebSocket or an Air or Sky broadcast. A Sky row has no temperature and an Air row has no wind, so the fields it doesn't measure are nil.
- `StationObservations` and `DeviceObservations` wrap the rows with the response's type, source, units and status. The device response also has a `DeviceSummary` for the latest row.

## Conditions and statistics

- `StationConditions` is the station's latest reading combined from every device, plus the API's calculated values and its RainCheck totals. It's the closest thing to "what is it doing right now".
- `CalculatedValues` holds feels like, heat index, wind chill, dew point, wet bulb, wet bulb globe, delta T, air density and the pressure trend. TempestKit doesn't calculate any of them.
- `StationStatistics` has one `Day` per day the station has data for, with averages, highs and lows, plus weekly, monthly, yearly and all-time rows. `Times` says when each value in an aggregate happened.

## Stations

- `WeatherStation` has the ID, name, location, time zone, elevation, sharing flags, capabilities, state, devices, items and the dates it was created and changed. There's no data before the creation date.
- `WeatherStation.Device` is the hub or sensor: its type, serial number, firmware, hardware revision, notes, placement (`Meta`) and the owner's settings. `station.hub` finds the hub.
- `StationSet` is the station list with the API's status object.

## Forecast

`TempestForecast` holds current conditions, the hourly forecast and the daily forecast from one request. It also keeps the forecast's station details, icons, precipitation types, response units and the API's status. `TempestForecast.Hour` and `.Day` are the rows.

## Status

`ResponseStatus` is the `status` object the API puts in every response. A zero code means success. The status also appears on `StationSet`, `StationObservations`, `DeviceObservations`, `StationConditions`, `StationStatistics` and `TempestForecast`.
