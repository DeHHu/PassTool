#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

swift package reset
rm -rf .build
OPENSSL_PREFIX="$ROOT/.vendor/openssl" \
swift build -c release -Xswiftc -Osize
strip .build/release/PassTool
ls -lh .build/release/PassTool
