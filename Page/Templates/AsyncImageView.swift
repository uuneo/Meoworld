//
//  AsyncImageView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI
import Photos


struct AvatarView: View {
    
    var id:String?
    
    var icon:String?
    
    var mode:String?
    
    var imageMode:ContentMode = .fill
    
    
    @State private var success:Bool = true
    
    @AppStorage(BaseConfig.activeAppIcon) var setting_active_app_icon:appIcon = .def
    @State private var image: UIImage?
    @State private var toastText:String = ""
    
    
    var body: some View {
        
        Group{
            if let icon = icon, isValidURL(icon), success{
                if let image = image {
                    // 如果已经加载了图片，则显示图片
                    Image(uiImage: image)
                        .resizable()
                    
                } else {
                    // 如果图片尚未加载，则显示加载中的视图
                    ProgressView()
                    
                }
            }else{
                if mode == "1"{
                    Image(appIcon.zero.logo)
                        .resizable()
                }else{
                    Image(setting_active_app_icon.logo)
                        .resizable()
                }
            }
            
        }
        .aspectRatio(contentMode: imageMode)
        .onChange(of: icon) { value in
            loadImage(icon: value)
        }
        .onAppear {
            loadImage(icon: icon)
        }
        
    }
    
    private func isValidURL(_ string: String) -> Bool {
        // 尝试将字符串转换为 URL 对象
        guard let url = URL(string: string) else { return false }
        
        // 检查 URL 对象是否有 scheme 和 host
        return url.scheme != nil && url.host != nil
    }
    private func loadImage(icon:String? ) {
        self.image = nil
        
        guard let icon = icon, isValidURL(icon) else {
            self.success = false
            return
        }
        
        Task {
            if let imagePath = await ImageManager.downloadImage(icon) {
				await MainActor.run {
                    self.image = UIImage(contentsOfFile: imagePath)
                }
            } else {
				await MainActor.run {
                    self.success = false
                }
            }
        }
    }
}
