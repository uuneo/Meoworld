//
//  ServerInfo.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation


struct serverInfo: Codable, Identifiable,Equatable{
    var id:UUID = UUID()
    var url:String
    var key:String
    var status:Bool = false
    
    var name:String{
        var name = url
        if let range = url.range(of: "://") {
           name.removeSubrange(url.startIndex..<range.upperBound)
        }
        return name
    }
    
    enum CodingKeys: CodingKey {
        case id
        case url
        case key
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.url = try container.decode(String.self, forKey: .url)
        self.key = try container.decode(String.self, forKey: .key)
        self.status = try container.decode(Bool.self, forKey: .status)
    }
    
    init(url:String, key: String,statues:Bool = false){
        self.url = url
        self.key = key
        self.status = statues
    }
    
    static let serverDefault = serverInfo(url: otherUrl.defaultServer, key: "")
  
}
