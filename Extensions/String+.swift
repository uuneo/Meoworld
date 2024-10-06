//
//  String+.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation

enum ImageType{
	case remote
	case local
	case none
}


extension String{
    func removeHTTPPrefix() -> String {
        var cleanedURL = self
        if cleanedURL.hasPrefix("http://") {
            cleanedURL = cleanedURL.replacingOccurrences(of: "http://", with: "")
        } else if cleanedURL.hasPrefix("https://") {
            cleanedURL = cleanedURL.replacingOccurrences(of: "https://", with: "")
        }
        return cleanedURL
    }
	
	// 判断字符串是否为 URL 并返回类型
	   func isValidURL() -> ImageType {
		   // 尝试将字符串转换为 URL 对象
		   guard let url = URL(string: self) else { return .none }
		   
		   debugPrint("加载图片：",url)
		   
		   // 检查是否是远程 URL（判断 scheme 是否为 http 或 https）
		   if let scheme = url.scheme, (scheme == "http" || scheme == "https") {
			   return .remote
		   }
		   
		   // 检查是否是本地文件路径（判断 scheme 是否为 file）
		   if url.isFileURL {
			   return .local
		   }
		   
		   // 如果既不是远程 URL 也不是本地文件路径，返回 none
		   return .none
	   }
	
	
	func isValidEmail() -> Bool {
		let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
		return emailTest.evaluate(with: self)
	}
}


