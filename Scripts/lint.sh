#!/bin/bash
#
# lint.sh
#
# Runs SwiftLint over the package. `--strict` turns warnings into failures, so
# this is the gate to run before a push. The pre-commit hook runs it too.
#
# SwiftLint isn't a package dependency: it's a tool you install on the machine.
# The build plugin the apps use downloads a macOS binary, which would get in the
# way of the Linux build.
#
# Usage:
#   lint.sh

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if ! command -v swiftlint >/dev/null 2>&1; then
    echo 'SwiftLint is not on PATH. Install it with "brew install swiftlint".' >&2
    exit 1
fi

exec swiftlint lint --strict --quiet
