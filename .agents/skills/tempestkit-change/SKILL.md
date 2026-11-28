---
name: tempestkit-change
description: Use when changing TempestKit, the WeatherFlow Tempest REST client: adding or fixing an endpoint, a model or an error; running its tests; building it for every platform it claims; or releasing a version.
---

# Changing TempestKit

`AGENTS.md` is the full guide — platform floor, naming, comments, doc comments, prose, commits. This is the procedure.

## 1. What the package is

Foundation only, no dependencies, and that's deliberate: it's what keeps the Linux build working. Adding a dependency is a conversation before it's a commit. macOS, iOS, tvOS and watchOS 26; raising a floor is a breaking change, so check `Package.swift` before reaching for an API.

## 2. Rules that bite

- Public methods throw `TempestError` and nothing else. A new failure maps into that type, not a bare `URLError` or `DecodingError` — `async throws(TempestError)` is the promise.
- Network and JSON work runs `@concurrent`. Swift 6.2 puts nonisolated async code on the caller's actor, and a weather call from a view model must not download or decode on the main thread.
- No `try?`. Handle the error or throw it.
- Tests are Swift Testing (`@Test`, `#expect`, `#require`) against `StubTransport` — no network, no token.
- Never put a token, or a query string carrying one, in an error or a log line.
- User-facing `errorDescription` text starts with "Unable to...".

## 3. Prove it

```sh
swift build
swift test
./Scripts/lint.sh

xcodebuild -scheme TempestKit -destination 'generic/platform=iOS' \
  -derivedDataPath "$TMPDIR/tk" CODE_SIGNING_ALLOWED=NO build
```

Repeat the last line with `tvOS` and `watchOS`. The Linux build is part of the claim, so don't reach for anything that only exists in Darwin frameworks.

## 4. Before handing it back

`AGENTS.md` ends with a six-step check — run it. In short: search the diff for "wire", "answers", "reads as", "rather than", "by design", "ensure"; read new comments out loud; check each new name is something you'd say to another developer; delete comments that repeat the code; say so where you're unsure; American spelling, except Apple's names and saved JSON keys.

## 5. Release

1. Commit: short, Title Case, present tense, no colon-and-tagline, no `Co-Authored-By`. One idea per commit. An assistant's body ends with the trailer `Assisted-by: AI (<model>)`.
2. Tag and push branch and tag by name (`--follow-tags` skips lightweight tags):

   ```sh
   git push github main
   git push github v1.1.0
   ```

3. A consumer that pins an exact version raises its requirement and resolves on
   its side. The package needs nothing else from it.

## Checklist

- [ ] Foundation only, no new dependency
- [ ] `swift build` and `swift test` pass, `./Scripts/lint.sh` is clean; every platform builds with `CODE_SIGNING_ALLOWED=NO`
- [ ] Errors still land in `TempestError`, no token in a message or log
- [ ] The six-step prose check done
- [ ] An assistant's commit ends with the trailer `Assisted-by: AI (<model>)`, with no `Co-Authored-By`
- [ ] Tagged and pushed
