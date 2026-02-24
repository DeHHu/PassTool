//
//  Manifest.swift
//  PassTool
//
//  Created by Денис Садаков on 24.02.2026.
//

import Foundation

public func createManifest(passJSONURL: URL, filesFolderURL: URL,  outFolderURL: URL) throws {
	let contents = try FileManager.default.contentsOfDirectory(at: filesFolderURL, includingPropertiesForKeys: nil,options: .skipsHiddenFiles)
	
	var pass = try Data(contentsOf: passJSONURL)
	
	var dict: [String:String] = [:]
	if let sha1 = SHA1.hexString(from: &pass)?.replacingOccurrences(of: " ", with: "").lowercased() {
		dict["pass.json"] = sha1
	}
	contents.forEach {
		let data = try? Data(contentsOf: $0)
		guard var data = data else {
			return
		}
		if let sha1 = SHA1.hexString(from: &data)?.replacingOccurrences(of: " ", with: "").lowercased() {
			dict[$0.lastPathComponent] = sha1
		}
	}
	let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted,.sortedKeys])
	
	let writeUrl = URL(filePath: outFolderURL.appending(path: "manifest").appendingPathExtension("json").path(percentEncoded: false))
	
	try jsonData.write(to: writeUrl)
	
	print("Файл \(writeUrl) успешно создан.")
}
