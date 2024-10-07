//
//  NewMessageModal.swift
//  Meow
//
//  Created by He Cho on 2024/10/7.
//
import Foundation
import SwiftData

@Model
class NewMessage: Codable {
	@Attribute(.unique) var id:String = UUID().uuidString
	var title:String?
	var body:String?
	var icon:String?
	var group:String?
	var url:String?
	var from:String?
	var mode:String?
	var createDate = Date()
	var read:Bool = false
	
	init(title: String? = nil, body: String? = nil, icon: String? = nil, group: String? = nil, url: String? = nil, from: String? = nil, mode: String? = nil, createDate: Date = Date(), read: Bool = false) {
		self.title = title
		self.body = body
		self.icon = icon
		self.group = group
		self.url = url
		self.from = from
		self.mode = mode
		self.createDate = createDate
		self.read = read
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
		try container.encodeIfPresent(self.title, forKey: .title)
		try container.encodeIfPresent(self.body, forKey: .body)
		try container.encodeIfPresent(self.icon, forKey: .icon)
		try container.encodeIfPresent(self.group, forKey: .group)
		try container.encodeIfPresent(self.url, forKey: .url)
		try container.encodeIfPresent(self.from, forKey: .from)
		try container.encodeIfPresent(self.mode, forKey: .mode)
		try container.encode(self.createDate, forKey: .createDate)
		try container.encode(self.read, forKey: .read)
	}
	
	required init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try container.decode(String.self, forKey: .id)
		self.title = try container.decodeIfPresent(String.self, forKey: .title)
		self.body = try container.decodeIfPresent(String.self, forKey: .body)
		self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
		self.group = try container.decodeIfPresent(String.self, forKey: .group)
		self.url = try container.decodeIfPresent(String.self, forKey: .url)
		self.from = try container.decodeIfPresent(String.self, forKey: .from)
		self.mode = try container.decodeIfPresent(String.self, forKey: .mode)
		self.createDate = try container.decode(Date.self, forKey: .createDate)
		self.read = try container.decode(Bool.self, forKey: .read)
	}
}

