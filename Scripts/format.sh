#!/bin/bash

cd "$(git rev-parse --show-toplevel)" || exit 1

case "${1:-}" in
--check)
    swift format lint --strict --configuration .swift-format --recursive Sources
    ;;
*)
    swift format --configuration .swift-format --recursive Sources -i
    ;;
esac
