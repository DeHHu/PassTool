//
//  main.swift
//  PassTool
//
//  Created by Денис Садаков on 20.02.2026.
//

import Foundation
import PassSigner



func app() {
	guard let tempDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "temp", directoryHint: .isDirectory).appending(path: "passtool", directoryHint: .isDirectory) else {
		return
	}
	guard let certsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "cert", directoryHint: .isDirectory) else {
		return
	}
	let manifestURL = URL(filePath: tempDir.appending(path: "manifest").appendingPathExtension("json").path(percentEncoded: false))
	guard FileManager.default.fileExists(atPath: manifestURL.path(percentEncoded: false)) else {
		return
	}
	let outURL = URL(filePath: tempDir.appending(path: "signature").path(percentEncoded: false))
	
	
	let signerCertUrl = URL(filePath: certsDir.appending(path: "signerCert").appendingPathExtension("pem").path(percentEncoded: false))
	guard FileManager.default.fileExists(atPath: signerCertUrl.path(percentEncoded: false)) else {
		return
	}
	let signerKeyUrl = URL(filePath: certsDir.appending(path: "signerKey").appendingPathExtension("pem").path(percentEncoded: false))
	guard FileManager.default.fileExists(atPath: signerKeyUrl.path(percentEncoded: false)) else {
		return
	}
	let wwdrCertUrl = URL(filePath: certsDir.appending(path: "wwdr").appendingPathExtension("pem").path(percentEncoded: false))
	guard FileManager.default.fileExists(atPath: wwdrCertUrl.path(percentEncoded: false)) else {
		return
	}
	let contents = try? FileManager.default.contentsOfDirectory(atPath: certsDir.path(percentEncoded: false))
	
	let pkPassUrl = URL(filePath: tempDir.appending(path: "pass").appendingPathExtension("pkpass").path(percentEncoded: false))
	print(contents ?? [])
	do {
		try signPKPassManifestDER(
			manifestURL: manifestURL,
			signerCertPEM: signerCertUrl,
			signerKeyPEM: signerKeyUrl,
			signerKeyPassword: "dragon",
			wwdrCertPEM: wwdrCertUrl,
			outSignatureURL: outURL
		)
		try zipPassDirectory(passDir: tempDir, outPKPass: pkPassUrl)
	} catch {
		print(error)
	}
	
}

private func zip(tempDirUrl: URL) throws {
	guard let filesUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appending(path: "temp", directoryHint: .isDirectory).appending(path: "certs", directoryHint: .isDirectory) else {
		return
	}
	guard FileManager.default.fileExists(atPath: filesUrl.path(percentEncoded: false)) else {
		return
	}
	let fileManager = FileManager.default
	
	let images = try fileManager.contentsOfDirectory(at: filesUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
	
	for image in images {
		let destinationUrl = tempDirUrl.appending(path: image.lastPathComponent)
		try fileManager.copyItem(at: image, to: destinationUrl)
	}
	
	let contents = try fileManager.contentsOfDirectory(at: tempDirUrl, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
		.map { $0.lastPathComponent }
	
	
	let archiveName = "\(UUID().uuidString.dropFirst(30)).pkpass"
	var arguments = ["-r", archiveName]
	arguments.append(contentsOf: contents)
	
	let process = Process()
	process.currentDirectoryURL = tempDirUrl
	process.launchPath = "/usr/bin/zip"
	process.arguments = arguments
	
	process.launch()
	process.waitUntilExit()
	
	let passUrl = tempDirUrl.appending(path: archiveName)
	if fileManager.fileExists(atPath: passUrl.path(percentEncoded: false)) {
		print("Полис успешно создан.")
	}
}

app()
