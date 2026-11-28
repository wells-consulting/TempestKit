# Errors

Every failure comes back as a `TempestError`, and each case tells you what happened.

The messages are short on purpose. Your app knows its users and should write the text they see.

| Case | What happened | What to do |
| --- | --- | --- |
| `.invalidRequest` | The parameters couldn't make a request. A negative day offset, for example. | Fix the call. |
| `.rangeTooLong(maxSpan:)` | The range is longer than one request can cover at that bucket size. | Split it with `windows(for:)`. `maxSpan` says how long one window can be. |
| `.network(URLError)` | The request never finished: no connection, a timeout, a dropped connection. | Check the connection and try again. The `URLError` says which. |
| `.listeningFailed(port:reason:)` | The UDP listener couldn't open its port. | Something else on the device probably has it. Close that listener and try again. |
| `.alreadyConnected` | The WebSocket already has a connection open. | Use the stream you have, or close it before opening another. |
| `.invalidResponse` | The API sent something that wasn't an HTTP response. | Treat it as a network problem. It usually means a proxy or a captive portal. |
| `.unauthorized` | The token was rejected with a 401. | Sign in again, or check the token. It may have been revoked. |
| `.rateLimited` | The API answered 429. | Wait, then try again. The limit isn't published, but a 429 clears within a minute or so. |
| `.httpStatus(code:path:)` | The API answered with another non-2xx status. | Log the code and path. A 404 or a 500 won't fix itself. |
| `.decoding(path:message:)` | The response wasn't the JSON, or the text, that was expected. | Treat it as a bug or an API change. `path` and `message` say where it broke. |
| `.noObservation` | The station has no usable observation. | Show a gap instead of a zero. The station may have no data for that range yet. |

## Catching one

```swift
do {
    let reading = try await client.latestObservation(station: id, token: myToken)
    show(reading)
} catch {
    switch error {
    case .unauthorized:
        signInAgain()
    case .rateLimited:
        showRetryLater()
    case .noObservation:
        showNoReading()
    default:
        showUnableToLoadReadings()
    }
}
```

The call is typed `async throws(TempestError)`, so `error` is already a `TempestError` inside the `catch`.

## What the client doesn't do

It doesn't cache, retry, wait between requests or log. Those depend on your app, so they're yours to add. It also never puts the token in an error, including the query string that carries it.
