//
//  CryptoManager.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import SwiftUI
import CryptoSwift
import SwiftyJSON
import Combine
import SwiftSMTP

class ToolsManager: ObservableObject {
    static let shared = ToolsManager()
    
    @AppStorage(BaseConfig.CryptoSettingFields,store: defaultStore) var fields:CryptoSettingFields = CryptoSettingFields.data
    
    @AppStorage(BaseConfig.archiveName,store: defaultStore) var archive:Bool = true
    
    @AppStorage(BaseConfig.badgemode, store: defaultStore) var badgeMode:badgeAutoMode = .auto
    
    @AppStorage(BaseConfig.emailConfig,store: defaultStore) var email:emailConfig = emailConfig.data
    
    // MARK: 解密
    func decrypt(ciphertext: String, iv: String? = nil) throws -> [AnyHashable: Any] {
        
        if let iv = iv {
            // Support using specified IV parameter for decryption
            fields.iv = iv
        }
        
        let aes = try AESCryptoModel(cryptoFields: fields)
        
        let json = try aes.decrypt(ciphertext: ciphertext)
        
        guard let data = json.data(using: .utf8), let map = JSON(data).dictionaryObject else {
            throw "JSON parsing failed"
        }
        
        var result: [AnyHashable: Any] = [:]
        for (key, val) in map {
            // 将key重写为小写
            result[key.lowercased()] = val
        }
        return result
    }
   
}


extension ToolsManager{
    static func startsWithHttpOrHttps(_ urlString: String) -> Bool {
        let pattern = "^(http|https)://.*"
        let test = NSPredicate(format:"SELF MATCHES %@", pattern)
        return test.evaluate(with: urlString)
    }

    
    
    static  func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else {
            return false // 无效的URL格式
        }
        
        // 验证协议头是否是http或https
        guard let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()) else {
            return false
        }
        
        // 验证是否有足够的点分隔符
        let components = url.host?.components(separatedBy: ".")
        return components?.count ?? 0 >= 2
    }
    
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    
    static func getGroup(_ group:String?)->String{
        return group ?? NSLocalizedString("defaultGroup",comment: "")
    }
    
    
    
     func changeBadge(badge:Int){
         
         dispatch_sync_safely_main_queue {
             if badge == -1{
                 UNUserNotificationCenter.current().setBadgeCount(0)
             }
             
             if self.badgeMode == .auto{
                 UNUserNotificationCenter.current().setBadgeCount(badge)
             }
         }
        
    }
}



extension ToolsManager{

    
    func sendMail(title:String,text:String, completionHandler: ((Error?) -> Void)? = nil){
        
        let smtp = SMTP(
            hostname: email.smtp,     // SMTP server address
            email: email.email,        // username to login
            password: email.password   // password to login
            // "illozqrqvcshbahi"
        )
        
        let mail = Mail(
            from: Mail.User(name: "Meoworld", email: email.email),
            to: email.toEmail.map({Mail.User(name: "Meoworld", email: $0.mail)}),
            subject: title,
            text:text
        )
        
        smtp.send(mail) { (error) in
            completionHandler?(error)
        }
        
    }

}


