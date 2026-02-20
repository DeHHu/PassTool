// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "PassTool",
	platforms: [
		.macOS(.v26)
	],
	products: [
		.executable(name: "PassTool", targets: ["PassTool"])
	],
	dependencies: [
		   .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.0")
	   ],
	targets: [
		// Clang-модуль: module.modulemap + shim.h должны лежать в Sources/COpenSSL/include/
		.target(
			name: "COpenSSL",
			publicHeadersPath: "include"
		),

		// Swift-логика: сюда кладём и -I, и -L/-l
		.target(
			name: "PassSigner",
			dependencies: ["COpenSSL",.product(name: "ZIPFoundation", package: "ZIPFoundation")],
			cSettings: [
				// ВАЖНО: include root, где лежит папка openssl/
				.unsafeFlags(["-I", ".vendor/openssl/include"])
			],
			linkerSettings: [
				.unsafeFlags(["-L", ".vendor/openssl/lib", "-lssl", "-lcrypto"]),
				.unsafeFlags(["-ldl", "-lpthread"], .when(platforms: [.linux]))
			]
		),

		.executableTarget(
			name: "PassTool",
			dependencies: ["PassSigner"]
		),

		.testTarget(
			name: "PassToolTests",
			dependencies: ["PassTool"]
		)
	]
)
