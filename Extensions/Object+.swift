//
//  Object+.swift
//  Meow
//
//  Created by He Cho on 2024/8/17.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers
import CryptoKit
import RealmSwift


struct Messages: Codable{
	var data:[Message]
	
	static func all() -> Messages {
		do{
			let realm = try Realm()
			return Messages(data: realm.objects(Message.self).compactMap({ $0 }))
		}catch{
			print(error.localizedDescription)
		}
		
		return Messages(data: [])
		
	}
}

struct encipherMessages:Codable{
	var data:[Message]
	
	static func all() -> encipherMessages {
		do{
			let realm = try Realm()
			return encipherMessages(data: realm.objects(Message.self).compactMap({ $0 }))
		}catch{
			print(error.localizedDescription)
		}
		
		return encipherMessages(data: [])
		
	}
}

extension Messages:Transferable{
	static var transferRepresentation: some TransferRepresentation{
		
		DataRepresentation(exportedContentType: .meowExportType){
			let data = try JSONEncoder().encode($0)
			return data
		}
		.suggestedFileName("Meowrld-\(Date().yyyyMMddhhmmss())")
	}
	enum EncryptionError:Error{
		case failed
	}
	

}

extension encipherMessages:Transferable{
	static var transferRepresentation: some TransferRepresentation{
		
		DataRepresentation(exportedContentType: .meowExportType){
			let data = try JSONEncoder().encode($0)
			guard (try AES.GCM.seal(data, using: .meowKey).combined) != nil else{
				throw EncryptionError.failed
			}
			return data
		}
		.suggestedFileName("Meowrld-\(Date().yyyyMMddhhmmss())")
		
			
	}
	enum EncryptionError:Error{
		case failed
	}

	

}




extension UTType{
	static var meowExportType = UTType(exportedAs: "me.uuneo.Meoworld.meow")
}

extension SymmetricKey{
	static var meowKey :SymmetricKey{
		let key = "iJUSTINE".data(using: .utf8 )!
		let sha256 = SHA256.hash(data: key)
		return .init(data: sha256)
	}
}


extension Date{
	func yyyyMMddhhmmss() -> String {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // 自定义格式
		return formatter.string(from: self)  // 返回格式化的日期字符串
	}
}

