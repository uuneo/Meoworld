//
//  ImageItemModal.swift
//  Meow
//
//  Created by He Cho on 2024/10/7.
//

import SwiftUI
import SwiftData

@Model
class ImageItem {
	@Attribute(.externalStorage)
	var key:String = UUID().uuidString
	var data: Data
	init(data: Data, key:String? = nil) {
		self.data = data
		if let key{
			self.key = key
		}
	}
}
