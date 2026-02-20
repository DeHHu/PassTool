#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENSSL_SRC="$ROOT/Vendor/openssl"
OUT="$ROOT/.vendor/openssl"

rm -rf "$OUT"
mkdir -p "$OUT"

cd "$OPENSSL_SRC"

# чистим прошлую сборку
make clean >/dev/null 2>&1 || true

# выбираем таргет для Configure
if [[ "$(uname -s)" == "Darwin" ]]; then
  # arm64/x86_64: OpenSSL сам определит, но можно форсить при желании
  ./Configure darwin64-arm64-cc no-shared no-dso no-tests --prefix="$OUT"
else
  ./Configure linux-x86_64 no-shared no-dso no-tests --prefix="$OUT"
fi

make -j"$(getconf _NPROCESSORS_ONLN 2>/dev/null || sysctl -n hw.ncpu)"
make install_sw install_ssldirs

echo "OpenSSL built into: $OUT"
echo "  include: $OUT/include"
echo "  libs:    $OUT/lib (libssl.a, libcrypto.a)"
