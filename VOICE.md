# Writing Code That Sounds Like Me

This is how I write Swift. If you're an agent working on TempestKit, read this
before you write a comment, a doc comment, a name, a log message, UI text, or
a commit message. The goal is code that reads like one person wrote it on a normal day,
not like a spec.

The short version: **plain words, short names, say what you mean, and it's OK
to sound like a person.**

---

## Comments

Write comments the way you'd explain something to a coworker looking over your
shoulder.

- **Use "we" and "I".** "We get here if..." "Not sure this is right."
  "I think this should be an `@ObservedObject` but that doesn't work."
- **Explain why, not what.** If the next line says `pageNumber += 1`, don't
  write `// Increment the page number`. Do write a comment when something is
  weird, surprising, or a workaround.
- **Admit doubt.** If you're unsure, say so. "This does NOT work without the
  delay. Why?" is a perfectly good comment. So is "This is a bit of a hack."
  Don't dress up a guess as a fact.
- **Short comments don't need a period.** `// No row matches` is fine.
  Multi-sentence comments get normal punctuation.
- **Step through a sequence with short labels.** When a function tries several
  things in order, mark each one:

  ```swift
  // First, try to match by name, ignoring case
  ...
  // Next, see if it's a station ID
  ...
  // Nothing matched
  return nil
  ```

- **List the cases when a branch has a reason.**

  ```swift
  // We get here if:
  //   1. We have observations locally, so we've synced before
  //   2. We have a last-fetched date, so we can just get what's new
  ```

- **Put units and plain values in a trailing comment.**

  ```swift
  config.timeoutIntervalForRequest = 30 // seconds
  static let maxDiskSize = 50 * 1024 * 1024 // 50MB
  static let maxAge: TimeInterval = 60 * 60 * 24 * 10 // 10 days
  ```

- **A little humor is fine.** A guard clause that bails on a non-2xx status can
  be headed `// Failure is not an option`. Don't force it, and don't do it often.
- **Open questions go in the code.** "We should discuss a value for this. 60
  seems... a little long" is better than silently picking a number.
- `// TODO:` is fine. Say what's left: `// TODO: Show loading rows?`

## Doc comments (`///`)

- Public API gets a doc comment. Most private and internal things don't.
- One plain sentence is usually enough. Add a second short paragraph only if
  there's a real gotcha the caller needs to know.
- Don't document every property of a model. If the name says it, skip it. Do
  document units and anything surprising (`/// kg/m³`, `/// Can be nil if the
  sensor failed`).
- No essays. If a doc comment is longer than the function, it's too long.

## Words to avoid

These make code sound generated. Use the plain word instead.

| Avoid                                       | Say                                             |
| ------------------------------------------- | ----------------------------------------------- |
| "the wire", "on the wire", "wire format"    | "the API", "the JSON", "the response"           |
| the API "answers", "echoes", "declares"     | the API "returns", "sends back"                 |
| a value "reads as" something                | "is treated as", "means", "shows up as"         |
| "minted", "vended", "surfaced"              | "created", "returned", "shown"                  |
| "by design", "deliberately"                 | just say what it does                           |
| "rather than" (over and over)               | "instead of", or split into two sentences       |
| "utilize", "leverage", "facilitate"         | "use", "help"                                   |
| "ensure", "guarantee"                       | "make sure", or just say what happens           |
| "authority", "canonical", "source of truth" | "the API says", "what we trust"                 |
| "consumer", "caller" in every sentence      | "you" in public docs, "we" in comments          |
| "confirmed live 2026-10-08"                 | leave dates out of code; put them in the commit |
| plan IDs in code (`GT-7`, `D-BT-c`, `F4`)    | say why; the ID goes in the commit body, if anywhere |
| "seam"                                      | "protocol", "hook", or name the thing           |
| "the X's own", "its own" (over and over)    | usually just drop "own"                         |
| a value or type "carries" something         | "has", "holds", "includes"                      |
| a feature "lands", "lands with"             | "is added", "comes in"                          |
| "honest", "honestly" (about data)           | say what it does: "leave it nil", "show a gap"  |
| a function "answers" or "stands behind"     | "returns", "trusts"                             |
| "never X, never Y" as a rule                | one plain sentence about what happens           |

**Punctuation:** an em dash (—) is fine now and then, the way you'd use one in
an email. It stops being fine when every other sentence has one, or when it's
carrying the sentence. A period, a comma, or parentheses usually read better.
Don't stack colons and semicolons into one long clever sentence. Two short
sentences beat one long one.

**Tone:** don't write aphorisms. "A failed sensor must read as a gap, never a
zero" sounds like a fortune cookie. "If a sensor fails we leave the value nil
instead of putting in a zero" sounds like me.

**Spelling:** American, everywhere: comments, names, log messages, UI text,
docs and commits. "color", not "colour". Same for "center", "gray",
"analyze", "canceled", "license" and "behavior". Apple's names stay the way
Apple spells them, even the odd British one like `Task.isCancelled`, and so do
keys that are already saved, column names and the JSON an API sends back.

## Naming

Name things what I'd call them out loud.

- **Short, common nouns for types.** `Barcode`, `Log`, `HTTP`, `Station`,
  `Observation`, `Forecast`. Not `WeatherStationEntity`,
  `ObservationRecordModel`, or `DerivedReadings`.
- **Namespace with enums and nested types** instead of long prefixed names:
  `HTTP.Method`, `HTTP.Header`, `Barcode.Options`, `Log.debug(...)`.
- **No coined compound names.** If you have to explain the name, pick a
  different one. `forecastShareWindow` should be `forecastCacheDuration`.
  `LogSink` should be `Logger` or `LogRecorder`. `init(wireValue:)` should be
  `init(rawValue:)`.
- **Plain verbs:** `get`, `add`, `remove`, `set`, `send`, `parse`, `process`,
  `reload`, `start`, `submit`, `first(matching:)`. Avoid `resolve`, `hydrate`,
  `materialize`, `reconcile`, `orchestrate`, `settle`, `synth`, `warm`, and
  `carryXForward`. Say what it does: `findDataStart`, `prefetchForecast`,
  `migrateHouseStyle`.
- **Plain nouns too.** `Provenance`, `Ledger`, `Verdict`, `Horizon` and
  `Gate` all need explaining. `Source`, `Table`, `Decision`, `TimeLeft` and
  `State` don't.
- **One word for one idea.** If the UI calls it a "source", don't call it a
  "vendor" in one file and a "provider" in another. Pick one and use it
  everywhere.
- **Terms of art win.** If an API uses a word a certain way, or it's the
  normal word in the field's own writing, use it in code even if I'd never
  pick it myself. `Tempest`, `station`, `observation`, `forecast` and `units` all stay. The UI can still say it more plainly. This only covers
  real terms, not words we made up that sound technical.
- **Booleans read like questions or statements:** `isFinished`,
  `isAuthenticated`, `didSuccessfullyAuthenticate`, `initialSyncComplete`,
  `useSampleData`.
- **Locals are short and obvious:** `page`, `pageNumber`, `fetchCount`,
  `results`, `text`, `rawText`, `data`, `index`. In tests, `v` for the thing
  under test and `v1Violations`, `v2Violations` is fine.
- **Don't over-qualify.** You don't need units in every property name when a
  doc comment can say it once. Pick one approach per type and stick with it.
- **UserDefaults keys** are snake_case strings in a `private static let
  somethingKey`.

## Code shape

- Early returns. `guard ... else { return }` near the top, then the main path.
- Blank lines between steps. A step comment goes above its block, sometimes
  with a blank line after it to set it apart.
- Long parameter lists wrap one per line, closing paren on its own line.
- `guard let self else { return }` in escaping closures.
- `// MARK: - Section Name` to break up a file. Title Case.
- Small helpers inside a function (a nested `func process(_ row:)`) are fine
  when only that function uses them.
- Prefer a clear, slightly repetitive `switch` over something clever.

## Log and error messages

- Plain and specific: `"Unable to parse barcode text '\(string)'"`,
  `"[\(requestID)] Request failed, delegate will handle it"`.
- User-facing error titles start with "Unable to...": "Unable to load
  stations".
- Request/response logs are terse: `[12] -> GET /stations, 0 bytes` and
  `[12] <- 200 OK, 4.2 KB, 183 ms`.

## Commit messages

- Short subject, Title Case, present tense that describes the change:
  "Fixes rate limiter burst", "Adds observation buckets", "Removes unused
  code", "Tries to fix the build server".
- Informal is fine: "Scan button weirdness" is a real subject line I wrote.
- No colons with a clever tagline ("Match the wire: live-verified stats...").
- Details, dates and links go in the body, if they're needed at all.
- If an assistant helped, end the message with the trailer
  `Assisted-by: AI (DeepSeek V4.1 Flash 1017)`, after a blank line. The
  parentheses name the model, so use the readable name the tool reports, not a
  provider slug. No `Co-Authored-By` trailer and no "Generated with" line,
  whichever agent wrote the commit.

---

## Before and after

These are from TempestKit, which I cleaned up this way. The "before" is the
generated voice.

### From TempestKit

**Doc comment on the client**

```swift
// Before
/// Token-agnostic by design: OAuth access tokens and personal access tokens
/// are the same opaque string on the wire (`token=` query parameter), so the
/// client neither stores one nor cares which flow minted it — every call
/// takes the token it should use.

// After
/// OAuth tokens and personal access tokens look the same to the API, so the
/// client doesn't care which kind you have. Pass one with every call.
```

**A cache constant**

```swift
// Before
/// How long one fetched forecast answers a second caller for the same
/// place without repeating the request. One screen commonly wants both
/// the hours and the days, which are the same payload's two halves; a
/// minute covers that without making the forecast stale.
private static let forecastShareWindow: TimeInterval = 60

// After
// A screen usually wants both the hourly and daily forecast, and they come
// back in the same response. Hang on to it for a minute so we don't ask twice.
private static let forecastCacheDuration: TimeInterval = 60 // 1 minute
```

**Latest observation**

```swift
// Before
/// The endpoint answers with its recent rows; the newest one that maps is
/// returned, so a failed sensor on the last row reads as the last good
/// reading rather than as no data at all.

// After
/// The station's most recent observation.
///
/// The API sends back a few recent rows. If the newest one is bad (a sensor
/// failed, say) we use the one before it instead of returning nothing.
```

**File-level comment**

```swift
// Before
// The wire format into the package's own models. Internal so a test can
// decode captured payloads without touching the network.

// After
// Converts API responses into our models. Internal so tests can decode
// saved JSON without hitting the network.
```

---

## Checklist before you hand back a change

1. Search your diff for "wire", "answers", "reads as", "rather than",
   "by design", "ensure", "seam", "carries", "own", and plan IDs. Rewrite any
   you find. Count the em dashes: a couple in a file is fine, a pile of them
   isn't.
2. Read each new comment out loud. If it sounds like documentation from a
   standards body, make it plainer.
3. For each new name, ask: would I say this out loud to another developer?
   Is it the same word the rest of the app uses for that thing?
4. Delete any comment that just repeats the code.
5. Is anything uncertain? Say so in a comment instead of hiding it.
6. Is everything spelled the American way? Search for "colour", "centre",
   "grey", "analyse", "behaviour" and "licence".
