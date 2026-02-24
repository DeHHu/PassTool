#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
swift package reset
rm -rf .build
OPENSSL_PREFIX="$ROOT/.vendor/openssl" swift build -v
OPENSSL_PREFIX="$ROOT/.vendor/openssl" swift run PassTool
