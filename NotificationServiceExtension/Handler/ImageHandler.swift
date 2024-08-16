//
//  ImageHandler.swift
//  NotificationServiceExtension
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import Kingfisher
import UniformTypeIdentifiers

class ImageHandler:NotificationContentHandler{
    func process(identifier: String, content bestAttemptContent: UNMutableNotificationContent) async throws -> UNMutableNotificationContent {
        let userInfo = bestAttemptContent.userInfo
        guard let imageUrl = userInfo["image"] as? String,
              let imageFileUrl = await ImageDownloader.downloadImage(imageUrl)
        else {
            return bestAttemptContent
        }
        
        let copyDestUrl = URL(fileURLWithPath: imageFileUrl).appendingPathExtension(".tmp")
        // 将图片缓存复制一份，推送使用完后会自动删除，但图片缓存需要留着以后在历史记录里查看
        try? FileManager.default.copyItem(
            at: URL(fileURLWithPath: imageFileUrl),
            to: copyDestUrl
        )
        
        if let attachment = try? UNNotificationAttachment(
            identifier: "image",
            url: copyDestUrl,
            options: [UNNotificationAttachmentOptionsTypeHintKey:UTType.png]
        ) {
            bestAttemptContent.attachments = [attachment]
        }
        return bestAttemptContent
    }
}


class ImageDownloader {
    /// 保存图片到缓存中
    /// - Parameters:
    ///   - cache: 使用的缓存
    ///   - data: 图片 Data 数据
    ///   - key: 缓存 Key
    class func storeImage(cache: ImageCache, data: Data, key: String) async {
        return await withCheckedContinuation { continuation in
            cache.storeToDisk(data, forKey: key, expiration: StorageExpiration.never) { _ in
                continuation.resume()
            }
        }
    }
    
    /// 使用 Kingfisher.ImageDownloader 下载图片
    /// - Parameter url: 下载的图片URL
    /// - Returns: 返回 Result
    class func downloadImage(url: URL) async -> Result<ImageLoadingResult, KingfisherError> {
        return await withCheckedContinuation { continuation in
            Kingfisher.ImageDownloader.default.downloadImage(with: url, options: nil) { result in
                continuation.resume(returning: result)
            }
        }
    }
   
    /// 下载推送图片
    /// - Parameter imageUrl: 图片URL字符串
    /// - Returns: 保存在本地中的`图片 File URL`
    class func downloadImage(_ imageUrl: String) async -> String? {
        guard let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: BaseConfig.groupName),
              let cache = try? ImageCache(name: "shared", cacheDirectoryURL: groupUrl),
              let imageResource = URL(string: imageUrl)
        else {
            return nil
        }
        
        // 先查看图片缓存
        if cache.diskStorage.isCached(forKey: imageResource.cacheKey) {
            return cache.cachePath(forKey: imageResource.cacheKey)
        }
        
        // 下载图片
        guard let result = try? await downloadImage(url: imageResource).get() else {
            return nil
        }
        // 缓存图片
        await storeImage(cache: cache, data: result.originalData, key: imageResource.cacheKey)
        
        return cache.cachePath(forKey: imageResource.cacheKey)
    }
}
