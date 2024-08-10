//
//  CiphertextHandler.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import SwiftyJSON


class CiphertextHandler: NotificationContentHandler {
    
    func process(identifier: String, content bestAttemptContent: UNMutableNotificationContent) async throws -> UNMutableNotificationContent {
        var userInfo = bestAttemptContent.userInfo
        guard let ciphertext = userInfo["ciphertext"] as? String else {
            return bestAttemptContent
        }
        
        // 如果是加密推送，则使用密文配置 bestAttemptContent
        do {
            var map = try ToolsManager.shared.decrypt(ciphertext: ciphertext, iv: userInfo["iv"] as? String)
            
            var alert = [String: Any]()
            var soundName: String? = nil
            if let title = map["title"] as? String {
                bestAttemptContent.title = title
                alert["title"] = title
            }
            if let body = map["body"] as? String {
                bestAttemptContent.body = body
                alert["body"] = body
            }
            if let group = map["group"] as? String {
                bestAttemptContent.threadIdentifier = group
            }
            if var sound = map["sound"] as? String {
                if !sound.hasSuffix(".caf") {
                    sound = "\(sound).caf"
                }
                soundName = sound
                bestAttemptContent.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: sound))
            }
            if let badge = map["badge"] as? Int {
                bestAttemptContent.badge = badge as NSNumber
            }
            var aps: [String: Any] = ["alert": alert]
            if let soundName {
                aps["sound"] = soundName
            }
            map["aps"] = aps
        
            userInfo = map
            bestAttemptContent.userInfo = userInfo
            return bestAttemptContent
        } catch {
            bestAttemptContent.body = "Decryption Failed"
            bestAttemptContent.userInfo = ["aps": ["alert": ["body": bestAttemptContent.body]]]
            throw NotificationContentHandlerError.error(content: bestAttemptContent)
        }
    }
    

}
