//
//  MessageModel.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import RealmSwift


final class Message: Object , ObjectKeyIdentifiable{
    @Persisted var id:String = UUID().uuidString
    @Persisted var title:String?
    @Persisted var body:String?
    @Persisted var icon:String?
    @Persisted var group:String?
    @Persisted var url:String?
    
    @Persisted var mode:String?
    @Persisted var createDate = Date()
    @Persisted var read:Bool = false
    
    override class func primaryKey() -> String? {
        return "id"
    }

    override class func indexedProperties() -> [String] {
        return ["group", "createDate"]
    }
}




extension Message:Codable{
    enum CodingKeys: String, CodingKey{
        case id, title, body, icon, group, url, mode ,createDate, read
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(body, forKey: .body)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encodeIfPresent(group, forKey: .group)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(mode, forKey: .mode)
        try container.encodeIfPresent(createDate, forKey: .createDate)
        try container.encodeIfPresent(read, forKey: .read)
       
    }
}





extension Message{
   
        static let messages = [
           
            Message(value: ["title":  NSLocalizedString("messageExampleTitle1",comment: ""),"group":  NSLocalizedString("messageExampleGroup1",comment: ""),"body": NSLocalizedString("messageExampleBody1",comment: ""),"icon":"warn","image":otherUrl.defaultImage,"cloud":true,"mode":"999"]),
            Message(value: ["group":NSLocalizedString("messageExampleGroup3",comment: ""),"title":NSLocalizedString("messageExampleTitle3",comment: "") ,"body":NSLocalizedString("messageExampleBody3",comment: ""),"url":"weixin://","icon":"weixin","cloud":true,"mode":"999"])
        ]
    
}
