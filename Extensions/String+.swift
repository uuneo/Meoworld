//
//  String+.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import Foundation

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
}
