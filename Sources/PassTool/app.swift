//
//  main.swift
//  PassTool
//
//  Created by Денис Садаков on 20.02.2026.
//

import Foundation
import PassSigner
import ArgumentParser

@main
struct PassTool: ParsableCommand {
	@Option(name: .shortAndLong, help: "Signer KEY password!")
	var signerKeyPassword: String
	@Option(name: .shortAndLong, help: "Pass.json file path")
	var passJSONPath: String
	@Option(name: .shortAndLong, help: "Certifications folder path")
	var certFolderPath: String
	@Option(name: .shortAndLong, help: "Files folder path (images, etc.)")
	var filesFolderPath: String
	@Option(name: .shortAndLong, help: "Output folder path (images, etc.)")
	var outputFolderPath: String
	@Option(name: .shortAndLong, help: "Temporary folder path (default is /var/tmp)")
	var tempFolderPath: String = "/var/tmp"
	
	mutating func run() throws {
		let tempId = UUID().uuidString
		let contentsDir = URL(filePath: filesFolderPath)
		let certsDir = URL(filePath: certFolderPath)
		let outputDir = URL(filePath: outputFolderPath)
		let tempDir = URL(filePath: tempFolderPath).appending(path: tempId, directoryHint: .isDirectory)
		let passJSONFile = URL(filePath: passJSONPath)
		
		if !FileManager.default.fileExists(atPath: tempDir.path) {
			try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: false)
		}
		
		try FileManager.default.copyItem(at: passJSONFile, to: tempDir.appending(path: "pass").appendingPathExtension("json"))
		
		try createManifest(passJSONURL: passJSONFile, filesFolderURL: contentsDir, outFolderURL: tempDir)
		
		let manifestURL = URL(filePath: tempDir.appending(path: "manifest").appendingPathExtension("json").path(percentEncoded: false))
		guard FileManager.default.fileExists(atPath: manifestURL.path(percentEncoded: false)) else {
			return
		}
		
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
	
		
		let pkPassUrl = URL(filePath: outputDir.appending(path: tempId).appendingPathExtension("pkpass").path(percentEncoded: false))
		do {
			try signPKPassManifestDER(
				manifestURL: manifestURL,
				signerCertPEM: signerCertUrl,
				signerKeyPEM: signerKeyUrl,
				signerKeyPassword: signerKeyPassword,
				wwdrCertPEM: wwdrCertUrl,
				outSignatureURL: tempDir
			)
			try zipPassDirectory(imagesFolderURL: contentsDir, tempFolderURL: tempDir, outPKPass: pkPassUrl)
			if FileManager.default.fileExists(atPath: tempDir.path) {
				try FileManager.default.removeItem(at: tempDir)
			}
			print("Apple pass successfully signed and ready to be shared!")
		} catch {
			print(error)
		}
	}
}
