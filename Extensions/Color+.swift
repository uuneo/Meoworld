//
//  Color+.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation
import SwiftUI


extension Color {
	init(hex: String, alpha: Double = 1.0) {
		var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
		hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
		
		var rgb: UInt64 = 0
		
		Scanner(string: hexSanitized).scanHexInt64(&rgb)
		
		let red = Double((rgb & 0xFF0000) >> 16) / 255.0
		let green = Double((rgb & 0x00FF00) >> 8) / 255.0
		let blue = Double(rgb & 0x0000FF) / 255.0
		
		self.init(red: red, green: green, blue: blue, opacity: alpha)
	}
	
}


extension Color {
	
	static let appDarkGray = Color(hex: "#0C0C0C")
	static let appGray = Color(hex: "#0C0C0C").opacity(0.8)
	static let appLightGray = Color(hex: "#0C0C0C").opacity(0.4)
	static let appYellow = Color(hex: "#FFAC0C")
	
	//Booking
	static let appRed = Color(hex: "#F62154")
	static let appBookingBlue = Color(hex: "#1874E0")
	
	//Profile
	static let appProfileBlue = Color(hex: "#374BFE")
}
