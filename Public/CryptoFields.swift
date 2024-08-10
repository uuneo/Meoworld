//
//  CryptoFields.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//


import Foundation
import CryptoSwift


enum Algorithm: String, CaseIterable {
    case aes128 = "AES128"
    case aes192 = "AES192"
    case aes256 = "AES256"

    var modes: [String] {
        switch self {
        case .aes128, .aes192, .aes256:
            return ["CBC", "ECB", "GCM"]
        }
    }

    var paddings: [String] {
        switch self {
        case .aes128, .aes192, .aes256:
            return ["pkcs7"]
        }
    }

    var keyLength: Int {
        switch self {
        case .aes128:
            return 16
        case .aes192:
            return 24
        case .aes256:
            return 32
        }
    }
}

struct CryptoSettingFields: Codable,Equatable {
    var algorithm: String
    var mode: String
    var padding: String
    var key: String
    var iv: String
    
    
    init(algorithm: String, mode: String, padding: String, key: String, iv: String) {
        self.algorithm = algorithm
        self.mode = mode
        self.padding = padding
        self.key = key
        self.iv = iv
    }
    
    enum CodingKeys: CodingKey {
        case algorithm
        case mode
        case padding
        case key
        case iv
    }
    

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.algorithm = try container.decode(String.self, forKey: .algorithm)
        self.mode = try container.decode(String.self, forKey: .mode)
        self.padding = try container.decode(String.self, forKey: .padding)
        self.key = try container.decode(String.self, forKey: .key)
        self.iv = try container.decode(String.self, forKey: .iv)
    }
    
   
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.algorithm, forKey: .algorithm)
        try container.encode(self.mode, forKey: .mode)
        try container.encode(self.padding, forKey: .padding)
        try container.encode(self.key, forKey: .key)
        try container.encode(self.iv, forKey: .iv)
    }
    
    
    static let data = CryptoSettingFields(algorithm: "AES128", mode: "CBC", padding: "pkcs7", key: "",iv: "")
}

extension CryptoSettingFields: RawRepresentable{
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




struct AESCryptoModel {
    let key: String
    let mode: BlockMode
    let padding: Padding
    let aes: AES
    
    
    init(cryptoFields: CryptoSettingFields) throws {
        
       
        guard let algorithm = Algorithm(rawValue: cryptoFields.algorithm) else {
            throw "Invalid algorithm"
        }
        
        let key = cryptoFields.key
        if key == ""{
            throw "Key is missing"
        }

        guard algorithm.keyLength == key.count else {
            throw String(format: NSLocalizedString("enterKey", comment: ""), algorithm.keyLength)
        }
        

        var iv = ""
        if ["CBC", "GCM"].contains(cryptoFields.mode) {
            var expectIVLength = 0
            if cryptoFields.mode == "CBC" {
                expectIVLength = 16
            }
            else if cryptoFields.mode == "GCM" {
                expectIVLength = 12
            }

            let ivField = cryptoFields.iv
            
            if  ivField.count == expectIVLength {
                iv = ivField
            }
            else {
                throw String(format: NSLocalizedString("enterIv", comment: ""), expectIVLength)
            }
        }

        let mode: BlockMode
        switch cryptoFields.mode {
        case "CBC":
            mode = CBC(iv: iv.bytes)
        case "ECB":
            mode = ECB()
        case "GCM":
            mode = GCM(iv: iv.bytes)
        default:
            throw "Invalid Mode"
        }

        self.key = key
        self.mode = mode
        self.padding = Padding.pkcs7
        self.aes = try AES(key: key.bytes, blockMode: self.mode, padding: self.padding)
    }

    func encrypt(text: String) throws -> String {
        return try aes.encrypt(Array(text.utf8)).toBase64()
    }

    func decrypt(ciphertext: String) throws -> String {
        return String(data: Data(try aes.decrypt(Array(base64: ciphertext))), encoding: .utf8) ?? ""
    }
}
