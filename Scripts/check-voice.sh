#!/bin/bash
#
# check-voice.sh
#
# Counts the words and punctuation VOICE.md says to avoid, so we can see them
# go down as we clean up.
#
# Usage:
#   check-voice.sh                    Counts per folder, comments only
#   check-voice.sh <path>...          Same, for one or more paths
#   check-voice.sh --all              Count every line, not just comments
#   check-voice.sh --diff [rev]       Show added lines that hit, against rev
#                                     (default HEAD, so unstaged and staged
#                                     changes)
#
# It's grep, so expect some false hits ("own" in a normal sentence). It's a
# guide, not a gate. A couple of em dashes in a file is fine, so that column is
# just a count. The file header's dash is left out.
#
# The block below is the only part that differs between repos. Everything after
# it is the same in all five, so a fix belongs in every copy.

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# The file header line, so its dash isn't counted. Empty when the header has no
# dash to leave out.
HEADER_RE=""

# Counted when no path is given on the command line.
DEFAULT_PATHS=(Sources Tests)

# The repo's plan board lanes, as an extended regex. Empty when it has none.
PLAN_ID_RE=''

# Each check is "label|extended regex". Keep labels short, they're columns.
CHECKS=(
    "em dash|—"
    "en dash|[^0-9 ] ?– ?[^0-9 ]"
    "wire|\bwire\b"
    "answers|\banswer(s|ed|ing)?\b"
    "reads as|\breads? as\b"
    "rather than|rather than"
    "by design|by design|deliberately"
    "ensure|\bensure|\bguarantee"
    "seam|\bseams?\b"
    "carries|\bcarr(y|ies|ied)\b"
    "own|'s own\b|\bits own\b"
    "lands|\blands?( with)?\b"
    "honest|\bhonest"
)

if [[ -n "$PLAN_ID_RE" ]]; then
    CHECKS+=("plan ID|$PLAN_ID_RE")
fi

CHECKS+=("date|20[0-9]{2}-[0-9]{2}-[0-9]{2}")

COMMENT_RE='^[[:space:]]*//'

# MARK: - Diff mode

if [[ "${1:-}" == "--diff" ]]; then
    rev="${2:-HEAD}"
    hits=0
    # Added lines only, with the file name in front
    while IFS= read -r line; do
        for check in "${CHECKS[@]}"; do
            label="${check%%|*}"
            regex="${check#*|}"
            if grep -qiE -- "$regex" <<<"${line#*: }"; then
                printf '%-12s %s\n' "$label" "$line"
                hits=$((hits + 1))
            fi
        done
    done < <(git diff "$rev" --unified=0 --no-color -- . ':!VOICE.md' ':!**/check-voice.sh' |
        awk '/^\+\+\+ b\// { file = substr($0, 7); next }
             /^\+/ && !/^\+\+\+/ { print file ": " substr($0, 2) }')
    echo "$hits hits"
    exit 0
fi

# MARK: - Count mode

scope="comments"
if [[ "${1:-}" == "--all" ]]; then
    scope="all"
    shift
fi

paths=("$@")
if [[ ${#paths[@]} -eq 0 ]]; then
    paths=("${DEFAULT_PATHS[@]}")
fi

# Header row
printf '%-34s' "folder"
for check in "${CHECKS[@]}"; do
    printf '%12s' "${check%%|*}"
done
printf '%10s\n' "total"

# Folders one level down from each path, so a big folder gets broken up
folders=()
for path in "${paths[@]}"; do
    [[ -e "$path" ]] || { echo "No such path: $path" >&2; exit 1; }
    if [[ -d "$path" ]] && compgen -G "$path/*/" >/dev/null; then
        while IFS= read -r dir; do folders+=("${dir%/}"); done < <(ls -d "$path"/*/)
        # Files sitting right in the folder count as the folder itself
        if compgen -G "$path/*.swift" >/dev/null; then folders+=("$path/*.swift"); fi
    else
        folders+=("$path")
    fi
done

declare -a totals
for folder in "${folders[@]}"; do
    # shellcheck disable=SC2086 # the *.swift entry needs to glob
    text="$(git ls-files -z -- $folder | grep -z '\.swift$' | xargs -0 cat 2>/dev/null || true)"
    [[ -n "$text" ]] || continue
    if [[ "$scope" == "comments" ]]; then
        text="$(grep -E "$COMMENT_RE" <<<"$text" || true)"
    fi
    if [[ -n "$HEADER_RE" ]]; then
        text="$(grep -vF "$HEADER_RE" <<<"$text" || true)"
    fi

    printf '%-34s' "$folder"
    row=0
    for i in "${!CHECKS[@]}"; do
        regex="${CHECKS[$i]#*|}"
        count="$(grep -ciE -- "$regex" <<<"$text" || true)"
        printf '%12s' "$count"
        totals[i]=$(( ${totals[i]:-0} + count ))
        row=$((row + count))
    done
    printf '%10s\n' "$row"
done

printf '%-34s' "TOTAL"
grand=0
for i in "${!CHECKS[@]}"; do
    printf '%12s' "${totals[i]:-0}"
    grand=$((grand + ${totals[i]:-0}))
done
printf '%10s\n' "$grand"
