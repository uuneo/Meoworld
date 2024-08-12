//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import UserNotifications


class NotificationService: UNNotificationServiceExtension {

    /// 当前正在运行的 Processor
    var currentNotificationProcessor: NotificationContentHandler? = nil
    /// 当前 ContentHandler，主要用来 serviceExtensionTimeWillExpire 时，传递给 Processor 用来交付推送。
    var currentContentHandler: ((UNNotificationContent) -> Void)? = nil

    
    
    
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        Task {
            guard var bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
                contentHandler(request.content)
                return
            }
            self.currentContentHandler = contentHandler
            
            // 所有的 processor， 按顺序从上往下对推送进行处理
            // ciphertext 需要放在最前面，有可能所有的推送数据都在密文里
            // call 需要放在最后面，因为这个 Processor 不会主动退出， 会一直等到 ServiceExtension 被终止
            let processors: [NotificationContentHandlerItem] = [
                .ciphertext,
                .level,
                .autoCopy,
                .archive,
                .setIcon,
                .setImage,
                .call
            ]
            
            // 各个 processor 依次对推送进行处理
            for processor in processors.map({ $0.processor }) {
                do {
                    self.currentNotificationProcessor = processor
                    bestAttemptContent = try await processor.process(identifier: request.identifier, content: bestAttemptContent)
                } catch NotificationContentHandlerError.error(let content) {
                    contentHandler(content)
                    return
                }
            }
            
            // 处理完后交付推送
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        super.serviceExtensionTimeWillExpire()
        if let handler = self.currentContentHandler {
            self.currentNotificationProcessor?.serviceExtensionTimeWillExpire(contentHandler: handler)
        }
    }

}
