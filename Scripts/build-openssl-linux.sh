#!/usr/bin/env bash
set -euo pipefail

# Build OpenSSL 3.6.x (static libs only) for Debian x86_64
# Output:
#   .vendor/openssl/include/...
#   .vendor/openssl/lib/libcrypto.a
#   .vendor/openssl/lib/libssl.a

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OPENSSL_SRC="$ROOT/Vendor/openssl"
OUT="$ROOT/.vendor/openssl"

echo "ROOT=$ROOT"
echo "OPENSSL_SRC=$OPENSSL_SRC"
echo "OUT=$OUT"

if [[ ! -d "$OPENSSL_SRC" ]]; then
  echo "ERROR: OpenSSL sources not found at: $OPENSSL_SRC" >&2
  exit 1
fi

rm -rf "$OUT"
mkdir -p "$OUT"

cd "$OPENSSL_SRC"

# Clean previous build artifacts (ignore if not built yet)
make clean >/dev/null 2>&1 || true

# Configure for Debian x86_64, static only, no CLI/apps
./Configure linux-x86_64 \
  no-apps no-tests no-shared no-dso \
  --prefix="$OUT" --libdir=lib \
  -fPIC

# Build only libraries (prevents building apps/openssl)
make -j"$(nproc)" build_libs

# Install headers/configs (libs may not be copied by install_sw in some setups)
make install_sw install_ssldirs

# Force-copy static libs (reliable fallback)
mkdir -p "$OUT/lib"
cp -v "$OPENSSL_SRC/libcrypto.a" "$OUT/lib/"
cp -v "$OPENSSL_SRC/libssl.a" "$OUT/lib/"

# Sanity checks
test -f "$OUT/include/openssl/bio.h"
test -f "$OUT/lib/libcrypto.a"
test -f "$OUT/lib/libssl.a"

echo "Done."
echo "Include: $OUT/include"
echo "Libs:    $OUT/lib"
ls -la "$OUT/lib" | sed -n '1,200p'
