//
//  ArchiveHandler.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import RealmSwift

class ArchiveHandler: NotificationContentHandler{
    private lazy var realm: Realm? = {
        Realm.Configuration.defaultConfiguration = kRealmDefaultConfiguration
        return try? Realm()
    }()
    
    func process(identifier: String, content bestAttemptContent: UNMutableNotificationContent) async throws -> UNMutableNotificationContent {
        let userInfo = bestAttemptContent.userInfo
        
        var isArchive: Bool =  ToolsManager.shared.archive
        
        if let archive = userInfo["isarchive"] as? String {
            isArchive = archive == "1" ? true : false
        }
        
        if isArchive {
            let alert = (userInfo["aps"] as? [String: Any])?["alert"] as? [String: Any]
            let title = alert?["title"] as? String
            let body = alert?["body"] as? String
            let url = userInfo["url"] as? String
            let group = userInfo["group"] as? String
            let icon = userInfo["icon"] as? String
            
            try? realm?.write {
                let message = Message()
                message.title = title
                message.body = body
                message.url = url
                message.group = group
                message.icon = icon
                message.createDate = Date()
                realm?.add(message)
            }
        }
        
        switch ToolsManager.shared.badgeMode {
        case .auto:
            // MARK: 通知角标 .custom
            if let badgeStr = bestAttemptContent.userInfo["badge"] as? String, let badge = Int(badgeStr) {
                bestAttemptContent.badge = NSNumber(value: badge)
            }
        case .custom:
            // MARK: 通知角标 .auto
            let messages = realm?.objects(Message.self).where {!$0.read}
            bestAttemptContent.badge = NSNumber(value:  messages?.count ?? 1)
        }
        
        return bestAttemptContent
    }
}
