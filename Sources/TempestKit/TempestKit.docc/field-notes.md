# Where the API and the Docs Disagree

A few fields and limits don't match WeatherFlow's documentation. TempestKit follows the API.

## Names in the response

- **`/stats/station` uses `first_ob_day_local` and `last_ob_day_local`.** The docs call them `first_ob_local_day` and `last_ob_local_day`. Both spellings are accepted when reading the response.
- **The row fields aren't in the docs.** A station observation row names its fields `air_temp`, `rh`, `wind_dir`, `precip_accumulation`, `local_day_precip_accumulation`, `strike_count`, `strike_distance`, `nc_precip_accumulation` and `nc_local_day_precip_accumulation`. Read rows by those names, not by position.
- **`current_conditions` spells lightning correctly.** The docs say `lighting_strike_*`, without the "n". The API sends `lightning_strike_*`.
- **`hub_status` has no `hub_sn`.** It uses `serial_number` for the hub, so a filter that only looks at `hub_sn` drops every hub status.
- **The device codes are `AR` and `SK`.** Not `AIR` and `SKY`; mapping those makes every Air and Sky come back as an unknown device.
- **Forecast icons are `possibly-*`.** The chances use `possibly-rainy-day`, `possibly-sleet-night` and so on. Part of the schema says `possible-*`; the API sends the longer spelling.

## Values and limits

- **Bigger buckets are summaries.** A 30-minute bucket over 30 days returns rows with `report_interval` set to 30, so the API built them from the minute data. It doesn't say whether each value is an average, a maximum or something else.
- **`obs_fields` is ignored.** Asking for three fields still returns all twenty. Use the names in the response, not the request.
- **Everything is metric.** A station set to °F returns °C readings and `station_units` still says `f`. The owner's choice is a display setting.
- **`/observations/device` stops at five days.** One-minute rows cover a range of five days or less.
- **A location forecast needs TempestOne.** `better_forecast?lat=...&lon=...` with a personal token returns 401.
- **Coordinates can be null.** The API's own `/stations` example has null latitude and longitude, so both are optional.

## The live messages

- **The Tempest row grew.** Firmware 193 sends 18 values. Newer rows add local-day rain at index 18, NearCast rain at 19, local-day NearCast rain at 20 and the precipitation analysis type at 21. UDP v171 documents only the first 18.
- **The WebSocket rain start has no timestamp.** It sends the type and device ID only, so it can't carry the date the UDP rain start has.
- **The lightning feed may need the add-on.** A personal token didn't acknowledge a `geo_strike_listen_start` in testing. The request and parser are there; the account may need TempestOne's lightning add-on.
