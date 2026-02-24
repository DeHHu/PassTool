#!/usr/bin/env bash
set -euo pipefail

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
mkdir -p "$OUT/lib" "$OUT/include"

cd "$OPENSSL_SRC"

make clean >/dev/null 2>&1 || true

OS="$(uname -s)"
ARCH="$(uname -m)"

if [[ "$OS" == "Darwin" ]]; then
  if [[ "$ARCH" == "arm64" ]]; then
    TARGET="darwin64-arm64-cc"
  else
    TARGET="darwin64-x86_64-cc"
  fi
elif [[ "$OS" == "Linux" ]]; then
  if [[ "$ARCH" == "x86_64" ]]; then
    TARGET="linux-x86_64"
  elif [[ "$ARCH" == "aarch64" ]]; then
    TARGET="linux-aarch64"
  else
    echo "Unsupported Linux arch: $ARCH" >&2
    exit 1
  fi
else
  echo "Unsupported OS: $OS" >&2
  exit 1
fi

echo "Configure target: $TARGET"

./Configure "$TARGET" \
  no-apps no-tests no-shared no-dso \
  --prefix="$OUT" --libdir=lib \
  -fPIC

# only libraries
if command -v nproc >/dev/null 2>&1; then
  JOBS="$(nproc)"
else
  JOBS="$(sysctl -n hw.ncpu 2>/dev/null || echo 4)"
fi

make -j"$JOBS" build_libs

# Install headers/configs if possible (libs may not be copied by install_sw on some setups)
make install_sw install_ssldirs || true

# Force-copy static libs (reliable fallback)
cp -v "$OPENSSL_SRC/libcrypto.a" "$OUT/lib/"
cp -v "$OPENSSL_SRC/libssl.a" "$OUT/lib/"

# Ensure headers exist (copy if install didn't)
if [[ ! -f "$OUT/include/openssl/bio.h" ]]; then
  mkdir -p "$OUT/include"
  cp -a "$OPENSSL_SRC/include/openssl" "$OUT/include/"
fi

# Sanity checks
test -f "$OUT/include/openssl/bio.h"
test -f "$OUT/lib/libcrypto.a"
test -f "$OUT/lib/libssl.a"

echo "Done."
echo "Include: $OUT/include"
echo "Libs:    $OUT/lib"
ls -la "$OUT/lib"
