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
# - no-apps: do not build openssl CLI (fixes FMT_istext link errors you saw)
# - no-tests: speeds up
# - no-shared/no-dso: static + no dynamic modules
# -fPIC is useful if you'll link these into other binaries
./Configure linux-x86_64 \
  no-apps no-tests no-shared no-dso \
  --prefix="$OUT" \
  -fPIC

# Build only libraries (prevents building apps/openssl)
make -j"$(nproc)" build_libs

# Install headers + static libs into $OUT
make install_sw install_ssldirs

echo "Done."
echo "Include: $OUT/include"
echo "Libs:    $OUT/lib"
ls -la "$OUT/lib" | sed -n '1,200p'
