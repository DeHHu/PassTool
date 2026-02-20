//
//  ZIP.swift
//  PassTool
//
//  Created by Денис Садаков on 20.02.2026.
//
import Foundation
import ZIPFoundation

public func zipPassDirectory(passDir: URL, outPKPass: URL) throws {
	if FileManager.default.fileExists(atPath: outPKPass.path) {
		try FileManager.default.removeItem(at: outPKPass)
	}
	let archive = try Archive(url: outPKPass, accessMode: .create)
	let files = try FileManager.default.contentsOfDirectory(at: passDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
	var signatureURL: URL? = nil
	var manifestURL: URL? = nil
	var passUrl: URL? = nil
	var images: [URL] = []
	
	for file in files {
		switch file.deletingPathExtension().lastPathComponent {
			case "manifest" : manifestURL = file
			case "pass": passUrl = file
			case "signature": signatureURL = file
			default: images.append(file)
		}
	}
	guard let signatureURL, let manifestURL, let passUrl, images.isEmpty == false else {
		throw NSError(domain: "PassTool", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось найти все необходимые файлы"])
	}
	try archive.addEntry(with: manifestURL.lastPathComponent, fileURL: manifestURL)
	try archive.addEntry(with: passUrl.lastPathComponent, fileURL: passUrl)
	try archive.addEntry(with: signatureURL.lastPathComponent, fileURL: signatureURL)
	for image in images {
		try archive.addEntry(with: image.lastPathComponent, fileURL: image)
	}
}
