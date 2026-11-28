# Ranges and Buckets

One request covers a limited span. Split a longer range into windows, and pick a bucket size that fits.

## Station history

`observations(station:range:bucket:token:)` returns the station's rows, oldest first. The range is inclusive, and the default bucket is the station's own once-a-minute readings.

A bigger bucket asks the API to summarize the same period into fewer rows. That also lets one request cover more time:

| Bucket | Each row covers | One request can cover |
| --- | --- | --- |
| `.oneMinute` | 1 minute | 1 day |
| `.fiveMinutes` | 5 minutes | 5 days |
| `.thirtyMinutes` | 30 minutes | 30 days |
| `.threeHours` | 3 hours | 180 days |
| `.oneDay` | 1 day | 4 years |

A range longer than the limit throws `TempestError.rangeTooLong`. Use `windows(for:)` to cut it into pieces the API will accept:

```swift
let week = Date.now.addingTimeInterval(-7 * 86_400)...Date.now

for window in ObservationBucket.oneMinute.windows(for: week) {
    let rows = try await client.observations(
        station: station.id,
        range: window,
        token: myToken
    )
    // Save the rows, then pause before the next request.
}
```

The rate limit is low, so wait between requests. TempestKit won't do it for you.

## What the bigger buckets mean

Only `.oneMinute` rows are real measurements. The API builds the others itself, and its docs don't say whether a value is an average, a maximum or something else. Treat them as a summary: good for a chart over a month, not for deciding what the wind did at 2:15.

## One device

`deviceObservations(device:range:token:)` has its own range type:

| Range | What you get |
| --- | --- |
| `.latest` | The most recent row |
| `.day(offset:)` | A whole UTC day. `0` is today, `1` is yesterday |
| `.range(_:)` | A range of up to five days at one-minute resolution |

Five days is the cap. `DeviceObservationRange.windows(for:)` splits a longer range:

```swift
let month = Date.now.addingTimeInterval(-30 * 86_400)...Date.now

for window in DeviceObservationRange.windows(for: month) {
    let response = try await client.deviceObservations(
        device: device.id,
        range: .range(window),
        token: myToken
    )
    // response.rows, response.summary
}
```

`deviceObservationsCSV(device:range:token:)` returns the same rows as CSV text. The five-day limit applies there too.

## Rows can be missing

A station row without a timestamp or an air temperature is dropped, so a range can return fewer rows than you expect. An empty array means the station has no data for that range, which is normal before it was installed. It isn't an error.
