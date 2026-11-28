# TempestKit

A Swift package for the WeatherFlow Tempest weather station: the REST client,
the WebSocket feed and the local UDP broadcasts. No package dependencies.

This file covers the platform floor, the Swift rules and the few things that
are TempestKit's own.

Read [VOICE.md](VOICE.md) before you write a comment, a doc comment, a name, a
log message, UI text, a commit message or a DocC article. If this file and
VOICE.md disagree, VOICE.md wins.

## Requirements

- Swift 6.2, Swift 6 language mode, strict concurrency.
- macOS 26, iOS 26, tvOS 26, watchOS 26. Raising the floor is a breaking
  change, so check `Package.swift` before reaching for an API.
- The REST client is Foundation only. `TempestKitUDP` adds `Network.framework`,
  and `TempestKitWebSocket` needs a libcurl with WebSockets on Linux. Every
  platform in the README has to build from the command line, Linux included.

## Dependencies

No package dependencies, on purpose. Nothing to resolve is what keeps the
Linux build cheap and `Package.swift` boring. Adding one is a conversation
before it's a commit. SwiftLint is a tool on the machine, not a dependency.

## Disclosure

`AI-DISCLOSURE.md` is the same file in every package I publish. If you change it, change it in all of them.

## Building

- `swift build` and `swift test` on the Mac.
- The other platforms, from the package directory:

  ```sh
  xcodebuild -scheme TempestKit -destination 'generic/platform=iOS' \
    -derivedDataPath "$TMPDIR/tk" CODE_SIGNING_ALLOWED=NO build
  ```

  Same line with `tvOS` or `watchOS` for the destination.

- `./Scripts/lint.sh` runs SwiftLint with the rules in `.swiftlint.yml`, and
  `--strict` makes warnings fail. It's a script instead of the build plugin the
  apps use, because that plugin downloads a macOS binary and the Linux build
  has to keep working. `.githooks/pre-commit` runs it when `core.hooksPath` is
  set.

- `./Scripts/format.sh` runs swift-format with `.swift-format`.
  It ships with the toolchain, so nothing is downloaded and the Linux build is
  unaffected.

## Swift

- Public methods throw `TempestError` and nothing else. That's what
  `async throws(TempestError)` promises, so a new failure has to map into that
  type instead of escaping as `URLError` or `DecodingError`.
- Network and JSON work runs `@concurrent`. Swift 6.2 runs nonisolated async
  code on the caller's actor, and a weather call from a view model should not
  download or decode on the main thread.
- No `try?`. Handle the error or throw it.
- Foundation habits: `appending(path:)`, `replacing(_:with:)`,
  `Date(_:strategy:)` and FormatStyle ahead of `Formatter` subclasses.
- Tests use Swift Testing: `@Test`, `#expect`, `#require`, `#expect(throws:)`.
  They run against `StubTransport`, so no network or token is involved.

## Doc comments

The public API is also the documentation site, so a public doc comment is
reference material, not conversation. These are the parts DocC needs on top of
what VOICE.md already says.

- Summary sentence first, then a discussion paragraph only if there's a gotcha:
  units, a fallback, an optional sensor, an API quirk.
- `- Parameter`, `- Returns` and `- Throws` on methods and initializers.
- One short example when the call is easier to show than to describe.

## Errors and messages

- Never put the token, or the query string that carries it, in an error or a
  log line.

## Commits

- One idea per commit, so a bad one is easy to back out.

## Repo references

- Never name or link another repository, app or internal project unless it's a
  direct dependency in `Package.swift`. That covers code, comments, docs, test
  fixtures, commit messages and issues. Another repo is private context; this
  one doesn't know it exists.

## Skills

The repo has one skill of its own, `tempestkit-change`, in `.agents/skills/` — the neutral path, which OpenCode reads. `.claude/skills/tempestkit-change` is a committed relative symlink to it, so Claude Code finds the same file on a fresh clone. Edit the real file, and keep its frontmatter to `name` and `description`: anything else belongs to one agent and the other ignores it.
