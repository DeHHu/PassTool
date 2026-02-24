// swift-tools-version: 6.2
import PackageDescription
import Foundation

let opensslPrefix = ProcessInfo.processInfo.environment["OPENSSL_PREFIX"] ?? ".vendor/openssl"

let package = Package(
	name: "PassTool",
	platforms: [
		.macOS(.v26)
	],
	products: [
		.executable(name: "PassTool", targets: ["PassTool"])
	],
	dependencies: [
		.package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0"),
		.package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0")
	],
	targets: [
		// C bridge only (modulemap + shim.h)
		.target(
			name: "COpenSSL",
			publicHeadersPath: "include"
		),

		.target(
			name: "PassSigner",
			dependencies: [
				"COpenSSL",
				.product(name: "ZIPFoundation", package: "ZIPFoundation")
			],
			cSettings: [
				// OpenSSL headers root (contains folder "openssl/")
				.unsafeFlags(["-I", "\(opensslPrefix)/include"])
			],
			linkerSettings: [
				// IMPORTANT: direct static libs (works better than -L/-l on Linux SwiftPM)
				.unsafeFlags([
					"\(opensslPrefix)/lib/libssl.a",
					"\(opensslPrefix)/lib/libcrypto.a"
				]),

				// Linux system libs commonly required by static OpenSSL
				.unsafeFlags(["-ldl", "-lpthread", "-lz", "-lm"], .when(platforms: [.linux]))
			]
		),

		.executableTarget(
			name: "PassTool",
			dependencies: [
				"PassSigner",
				.product(name: "ArgumentParser", package: "swift-argument-parser"),
			]
		),

		.testTarget(
			name: "PassToolTests",
			dependencies: ["PassTool"]
		)
	]
)
