//
//  PassSigner.swift
//  PassTool
//
//  Created by Денис Садаков on 20.02.2026.
//

import Foundation
import COpenSSL

public enum PassSignError: Error, CustomStringConvertible {
	case openSSL(String)
	case cannotCreateBIO
	case cannotReadCertificate
	case cannotReadPrivateKey
	case cannotReadInput
	case cannotWriteOutput

	public var description: String {
		switch self {
		case .openSSL(let s): return "OpenSSL error: \(s)"
		case .cannotCreateBIO: return "Cannot create BIO"
		case .cannotReadCertificate: return "Cannot read X509 certificate"
		case .cannotReadPrivateKey: return "Cannot read private key"
		case .cannotReadInput: return "Cannot read input file"
		case .cannotWriteOutput: return "Cannot write output file"
		}
	}
}

// MARK: - Helpers

private func openSSLErrorString() -> String {
	var messages: [String] = []
	while true {
		let code = ERR_get_error()
		if code == 0 { break }

		// OpenSSL пишет NUL-terminated строку в буфер
		var buf = [CChar](repeating: 0, count: 256)
		ERR_error_string_n(code, &buf, buf.count)

		// Swift 6: String(cString:) deprecated -> аккуратно декодим до NUL
		let bytes = buf.prefix { $0 != 0 }.map { UInt8(bitPattern: $0) }
		messages.append(String(decoding: bytes, as: UTF8.self))
	}
	return messages.isEmpty ? "Unknown" : messages.joined(separator: " | ")
}

private func withCStringPath<T>(_ url: URL, _ body: (UnsafePointer<CChar>) throws -> T) rethrows -> T {
	try url.path(percentEncoded: false).withCString { cstr in
		try body(cstr)
	}
}

// MARK: - PKPass signature (CMS/PKCS#7 DER)

/// Подписывает manifest.json для pkpass и пишет DER signature в outSignatureURL.
/// Эквивалентно:
/// `openssl smime -sign -in manifest -out signature -signer cert.pem -inkey key.pem -certfile wwdr.pem -outform der -binary`
public func signPKPassManifestDER(
	manifestURL: URL,
	signerCertPEM: URL,
	signerKeyPEM: URL,
	signerKeyPassword: String,
	wwdrCertPEM: URL,
	outSignatureURL: URL
) throws {

	_ = OPENSSL_init_crypto(0, nil)
	ERR_clear_error()

	// 1) BIO на входной manifest
	let inBio: OpaquePointer? = withCStringPath(manifestURL) { path in
		BIO_new_file(path, "rb")
	}
	guard let inBio else { throw PassSignError.cannotReadInput }
	defer { _ = BIO_free(inBio) }

	// 2) signer cert (X509) из PEM
	let certBio: OpaquePointer? = withCStringPath(signerCertPEM) { path in
		BIO_new_file(path, "rb")
	}
	guard let certBio else { throw PassSignError.cannotCreateBIO }
	defer { _ = BIO_free(certBio) }

	let signerX509: OpaquePointer? = PEM_read_bio_X509(certBio, nil, nil, nil)
	guard let signerX509 else {
		throw PassSignError.openSSL(openSSLErrorString())
	}
	defer { X509_free(signerX509) }

	// 3) приватный ключ (зашифрованный PEM)
	let keyBio: OpaquePointer? = withCStringPath(signerKeyPEM) { path in
		BIO_new_file(path, "rb")
	}
	guard let keyBio else { throw PassSignError.cannotCreateBIO }
	defer { _ = BIO_free(keyBio) }

	var passBuf = Array(signerKeyPassword.utf8CString) // NUL-terminated
	let signerPKey: OpaquePointer? = passBuf.withUnsafeMutableBytes { rawBuf in
		let p = rawBuf.baseAddress?.assumingMemoryBound(to: CChar.self)
		return PEM_read_bio_PrivateKey(keyBio, nil, nil, p)
	}
	guard let signerPKey else {
		throw PassSignError.openSSL(openSSLErrorString())
	}
	defer { EVP_PKEY_free(signerPKey) }

	// 4) WWDR cert (additional cert)
	let wwdrBio: OpaquePointer? = withCStringPath(wwdrCertPEM) { path in
		BIO_new_file(path, "rb")
	}
	guard let wwdrBio else { throw PassSignError.cannotCreateBIO }
	defer { _ = BIO_free(wwdrBio) }

	let wwdrX509: OpaquePointer? = PEM_read_bio_X509(wwdrBio, nil, nil, nil)
	guard let wwdrX509 else {
		throw PassSignError.openSSL(openSSLErrorString())
	}
	defer { X509_free(wwdrX509) }

	// 5) CMS_sign: detached + binary (аналог -binary)
	let flags: UInt32 = UInt32(CMS_DETACHED) | UInt32(CMS_BINARY)

	guard let cms = CMS_sign(signerX509, signerPKey, nil, inBio, flags) else {
		throw PassSignError.openSSL(openSSLErrorString())
	}
	defer { CMS_ContentInfo_free(cms) }

	// Добавляем WWDR сертификат в SignedData (аналог -certfile wwdr.pem)
	// CMS_add1_cert увеличивает refcount (add1), поэтому наш defer X509_free(wwdrX509) безопасен.
	if CMS_add1_cert(cms, wwdrX509) != 1 {
		throw PassSignError.openSSL(openSSLErrorString())
	}

	// 6) Пишем DER в outSignatureURL
	if FileManager.default.fileExists(atPath: outSignatureURL.path(percentEncoded: false)) {
		try FileManager.default.removeItem(at: outSignatureURL)
	}

	let outBio: OpaquePointer? = withCStringPath(outSignatureURL) { path in
		BIO_new_file(path, "wb")
	}
	guard let outBio else { throw PassSignError.cannotWriteOutput }
	defer { _ = BIO_free(outBio) }

	if i2d_CMS_bio(outBio, cms) != 1 {
		throw PassSignError.openSSL(openSSLErrorString())
	}
}
