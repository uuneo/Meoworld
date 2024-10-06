//
//  MessageModel.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import RealmSwift
import CoreTransferable
import CryptoKit


final class Message: Object , ObjectKeyIdentifiable, Codable {
    @Persisted var id:String = UUID().uuidString
    @Persisted var title:String?
    @Persisted var body:String?
    @Persisted var icon:String?
    @Persisted var group:String?
    @Persisted var url:String?
    @Persisted var from:String?
    
    @Persisted var mode:String?
    @Persisted var createDate = Date()
    @Persisted var read:Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }

    override class func indexedProperties() -> [String] {
        return ["group", "createDate", "from"]
    }
	
	enum CodingKeys: CodingKey {
		case id
		case title
		case body
		case icon
		case group
		case url
		case from
		case mode
		case createDate
		case read
	}
	
	
	func encode(to encoder: any Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.title, forKey: .title)
		try container.encode(self.body, forKey: .body)
		try container.encode(self.icon, forKey: .icon)
		try container.encode(self.group, forKey: .group)
		try container.encode(self.url, forKey: .url)
		try container.encode(self.from, forKey: .from)
		try container.encode(self.mode, forKey: .mode)
		try container.encode(self.createDate, forKey: .createDate)
		try container.encode(self.read, forKey: .read)
	}

}





extension Message{
   
        static let messages = [
           
            Message(value: ["title":  NSLocalizedString("messageExampleTitle1",comment: ""),"group":  NSLocalizedString("messageExampleGroup1",comment: ""),"body": NSLocalizedString("messageExampleBody1",comment: ""),"icon":"warn","image":otherUrl.defaultImage,"cloud":true,"mode":"999"]),
            Message(value: ["group":NSLocalizedString("messageExampleGroup3",comment: ""),"title":NSLocalizedString("messageExampleTitle3",comment: "") ,"body":NSLocalizedString("messageExampleBody3",comment: ""),"url":"weixin://","icon":"weixin","cloud":true,"mode":"999"])
        ]
    
}
