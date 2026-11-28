# Tokens and Sign-In

Get a token, pass it with every call, and know what a rejected one looks like.

The REST calls and the WebSocket feed take a token. TempestKit never stores it and never writes it to an error or a log line, so keeping it safe is up to your app.

## Personal access tokens

A personal token is the quickest way in. Sign in at [tempestwx.com](https://tempestwx.com), open Settings, then Data Authorizations, and create one.

Pass it with each call:

```swift
let client = TempestClient()
let stations = try await client.stations(token: myToken)
```

## OAuth

If your app has a sign-in screen, use OAuth. Register the app at [tempestwx.com/developers](https://tempestwx.com/developers), then pick one of the two flows:

| Flow | Authorize URL |
| --- | --- |
| Authorization code | `https://tempestwx.com/authorize.html` |
| Authorization code with PKCE | `https://smartweather.weatherflow.com/authorize.html` |

Both exchange the code at `POST https://swd.weatherflow.com/id/oauth2/token`. The authorization-code flow sends the client secret; PKCE sends the verifier instead.

The OAuth page and the swagger file disagree about which host serves the authorization page, so check which one your app is registered for.

TempestKit doesn't do the sign-in, run the redirect or keep the token. Finish that in your app, then pass the token to the client and the WebSocket the same way you pass a personal token:

```swift
let socket = TempestWebSocket(token: myToken)
```

`TempestWebSocket(apiKey:)` is for a developer API key instead of a token.

## When a token is rejected

The API returns a 401 for a bad token, and TempestKit throws `TempestError.unauthorized`. That's the signal to sign in again. A token that has been revoked looks the same.

Don't put the token in a request log, a crash report or an error message. The client doesn't, and the request's query string doesn't belong in yours either.
