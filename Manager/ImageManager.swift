//
//  ImageManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI
import Kingfisher


final class ImageManager{
    
    /// 保存图片到缓存中
    /// - Parameters:
    ///   - cache: 使用的缓存
    ///   - data: 图片 Data 数据
    ///   - key: 缓存 Key
    static  func storeImage(cache: ImageCache, data: Data, key: String) async {
        return await withCheckedContinuation { continuation in
            cache.storeToDisk(data, forKey: key, expiration: StorageExpiration.never) { _ in
                continuation.resume()
            }
        }
    }
    
    /// 使用 Kingfisher.ImageDownloader 下载图片
    /// - Parameter url: 下载的图片URL
    /// - Returns: 返回 Result
    static  func downloadImage(url: URL) async -> Result<ImageLoadingResult, KingfisherError> {
        return await withCheckedContinuation { continuation in
            Kingfisher.ImageDownloader.default.downloadImage(with: url, options: nil) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    
    /// 下载推送图片
    /// - Parameter imageUrl: 图片URL字符串
    /// - Returns: 保存在本地中的`图片 File URL`
    static func downloadImage(_ imageUrl: String) async -> String? {
        
        
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
        //        return result.originalData
    }
    
    
}


