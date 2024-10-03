//
//  CryptoManager.swift
//  Meow
//
//  Created by He Cho on 2024/10/3.
//

import Foundation
import CommonCrypto
import CryptoKit


enum AESMode: String, Codable,CaseIterable, RawRepresentable {
	case CBC, ECB, GCM
	var padding: String {
		self == .GCM ? "Space" : "PKCS7"
	}
}

enum AESAlgorithm: Int, Codable, CaseIterable,RawRepresentable {
	case AES128 = 16 // 16 bytes = 128 bits
	case AES192 = 24 // 24 bytes = 192 bits
	case AES256 = 32 // 32 bytes = 256 bits
	
	var name:String{
		self == .AES128 ? "AES128" : (self == .AES192 ? "AES192" : "AES256")
	}
}



struct AESData: Codable, Equatable{

	var algorithm: AESAlgorithm
	var mode: AESMode
	var key: String
	var iv: String
	
	static let data = AESData(algorithm: .AES256, mode: .GCM, key: generateRandomString(), iv: generateRandomString(by32: false))
	
	
	static func generateRandomString(by32:Bool = true) -> String {
		// 创建可用字符集（大写、小写字母和数字）
		let charactersArray = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
		
		return String(Array(1...(by32 ? 32 : 16)).compactMap { _ in charactersArray.randomElement() })
	}
	
	enum CodingKeys: String, CodingKey{
		case algorithm
		case mode
		case key
		case iv
	}
	
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(algorithm, forKey: .algorithm)
		try container.encodeIfPresent(mode, forKey: .mode)
		try container.encodeIfPresent(key, forKey: .key)
		try container.encodeIfPresent(iv, forKey: .iv)
	}
	
	init(algorithm: AESAlgorithm, mode: AESMode, key: String, iv: String) {
		self.algorithm = algorithm
		self.mode = mode
		self.key = key
		self.iv = iv
	}
	
	init(from decoder: any Decoder) throws {
		
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.algorithm = try container.decode(AESAlgorithm.self, forKey: .algorithm)
		self.mode = try container.decode(AESMode.self, forKey: .mode)
		self.key = try container.decode(String.self, forKey: .key)
		self.iv = try container.decode(String.self, forKey: .iv)
	}
	
	

	
	
}



extension AESData: RawRepresentable{
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8) ,
			  let result = try? JSONDecoder().decode(
				Self.self,from: data) else{
			return nil
		}
		self = result
	}

	public var rawValue: String {
		guard let result = try? JSONEncoder().encode(self),
			  let string = String(data: result, encoding: .utf8) else{
			return ""
		}
		return string
	}
}




class AESManager {
	
	private let algorithm: AESAlgorithm
	private let mode: AESMode
	private let key: Data
	private let iv: Data?
	

	init(_ data: AESData) {
		self.key = data.key.data(using: .utf8)!
		self.iv = data.iv.data(using: .utf8)!
		self.mode = data.mode
		self.algorithm = data.algorithm
	}


	// MARK: - Public Methods
	func encrypt(_ plaintext: String) -> Data? {
		guard let plaintextData = plaintext.data(using: .utf8) else { return nil }

		switch mode {
		case .CBC, .ECB:
			return commonCryptoEncrypt(data: plaintextData, operation: CCOperation(kCCEncrypt))
		case .GCM:
			return gcmEncrypt(data: plaintextData)
		}
	}
	

	func decrypt(_ ciphertext: Data) -> String? {
		switch mode {
		case .CBC, .ECB:
			guard let decryptedData = commonCryptoEncrypt(data: ciphertext, operation: CCOperation(kCCDecrypt)) else { return nil }
			return String(data: decryptedData, encoding: .utf8)
		case .GCM:
			guard let decryptedData = gcmDecrypt(data: ciphertext) else { return nil }
			return String(data: decryptedData, encoding: .utf8)
		}
	}
	
	// MARK: - Private Methods

	// CommonCrypto (CBC/ECB) Encryption/Decryption
	private func commonCryptoEncrypt(data: Data, operation: CCOperation) -> Data? {
		let algorithm = CCAlgorithm(kCCAlgorithmAES) // AES algorithm
		let options = mode == .CBC ? CCOptions(kCCOptionPKCS7Padding) : CCOptions(kCCOptionPKCS7Padding | kCCOptionECBMode)

		var numBytesEncrypted: size_t = 0
		let dataOutLength = data.count + kCCBlockSizeAES128
		var dataOut = Data(count: dataOutLength)
		
		let cryptStatus = dataOut.withUnsafeMutableBytes { dataOutBytes in
			data.withUnsafeBytes { dataInBytes in
				key.withUnsafeBytes { keyBytes in
					iv?.withUnsafeBytes { ivBytes in
						CCCrypt(operation,
								algorithm, // AES algorithm
								options,
								keyBytes.baseAddress!, key.count, // Key length based on key.count
								mode == .CBC ? ivBytes.baseAddress : nil, // Use IV for CBC, nil for ECB
								dataInBytes.baseAddress!, data.count,
								dataOutBytes.baseAddress!, dataOutLength,
								&numBytesEncrypted)
					} ?? CCCrypt(operation,
								 algorithm, // AES algorithm
								 options,
								 keyBytes.baseAddress!, key.count, // Key length based on key.count
								 nil, // No IV for ECB
								 dataInBytes.baseAddress!, data.count,
								 dataOutBytes.baseAddress!, dataOutLength,
								 &numBytesEncrypted)
				}
			}
		}

		if cryptStatus == kCCSuccess {
			return dataOut.prefix(numBytesEncrypted)
		}
		return nil
	}

	// CryptoKit (GCM) Encryption
	private func gcmEncrypt(data: Data) -> Data? {
		let symmetricKey = SymmetricKey(data: key)
		let nonce = AES.GCM.Nonce()
		do {
			let sealedBox = try AES.GCM.seal(data, using: symmetricKey, nonce: nonce)
			return nonce + sealedBox.ciphertext + sealedBox.tag // Nonce + Ciphertext + Tag
		} catch {
			print("GCM Encryption error: \(error)")
			return nil
		}
	}

	// CryptoKit (GCM) Decryption
	private func gcmDecrypt(data: Data) -> Data? {
		let nonceSize = 12
		let tagSize = 16

		guard data.count > nonceSize + tagSize else { return nil }

		let symmetricKey = SymmetricKey(data: key)
		let nonce = try? AES.GCM.Nonce(data: data.prefix(nonceSize))
		let ciphertext = data.dropFirst(nonceSize).dropLast(tagSize)
		let tag = data.suffix(tagSize)

		do {
			let sealedBox = try AES.GCM.SealedBox(nonce: nonce!, ciphertext: ciphertext, tag: tag)
			return try AES.GCM.open(sealedBox, using: symmetricKey)
		} catch {
			print("GCM Decryption error: \(error)")
			return nil
		}
	}
	

}

