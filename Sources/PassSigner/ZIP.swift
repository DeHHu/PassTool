//
//  ZIP.swift
//  PassTool
//
//  Created by Денис Садаков on 20.02.2026.
//
import Foundation
import ZIPFoundation

public func zipPassDirectory(imagesFolderURL: URL, tempFolderURL: URL, outPKPass: URL) throws {
	if FileManager.default.fileExists(atPath: outPKPass.path) {
		try FileManager.default.removeItem(at: outPKPass)
	}
	let archive = try Archive(url: outPKPass, accessMode: .create)
	let images = try FileManager.default.contentsOfDirectory(at: imagesFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
	let files = try FileManager.default.contentsOfDirectory(at: tempFolderURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
	var signatureURL: URL? = nil
	var manifestURL: URL? = nil
	var passUrl: URL? = nil
	for file in files {
		switch file.deletingPathExtension().lastPathComponent {
			case "manifest" : manifestURL = file
			case "pass": passUrl = file
			case "signature": signatureURL = file
			default: break
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
