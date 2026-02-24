swift package reset
rm -rf .build
OPENSSL_PREFIX="$PWD/.vendor/openssl" swift run PassTool
swift build -v
swift run PassTool
