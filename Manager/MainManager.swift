//
//  MainManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import SwiftUI
import Combine
import Network

class MainManager:ObservableObject {
   static let shared = MainManager()
    
    @AppStorage(BaseConfig.deviceToken, store: defaultStore) var deviceToken:String = ""
    @AppStorage(BaseConfig.voipDeviceToken,store: defaultStore) var voipDeviceToken = ""
    @AppStorage(BaseConfig.server) var servers:[serverInfo] = [serverInfo.serverDefault]
    
    
}


extension MainManager{
    func health(url: String) async-> Bool {
        do{
            if let health: String = try await NetworkManager.shared.fetchRaw(url: url){
                return health == "ok"
            }
        }catch{
            return false
        }
        
        return false
        
    }
    
    func openUrl(url: String ){
        if  let url = URL(string: url) {
            self.openUrl(url: url )
        }
    }
    
    
    
    func openUrl(url: URL) {
        if ["http", "https"].contains(url.scheme?.lowercased() ?? "") {
            UIApplication.shared.open(url, options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true]) { success in
                if !success {
                    // 打不开Universal Link时，则用内置 safari 打开

                    RouterManager.shared.webUrl = url.path()
                    RouterManager.shared.fullPage = .web
                }
            }
        }
        else {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
    func copy(text:String){
        UIPasteboard.general.string = text
    }
}



extension MainManager{
    func addServer(_ agreeName:String = "", url: String)-> (Bool,String){
        var toastText:String = ""
        
        
        let url = agreeName + url.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if url.count < (agreeName.count + 2){
            return (false, toastText)
        }
        
        
        if !ToolsManager.startsWithHttpOrHttps(url){
            toastText = NSLocalizedString("verifyFail",comment: "")
            return (false,toastText)
        }
        
        let count = self.servers.filter({$0.url == url}).count
        
        if count == 0{
            if serverInfo.serverDefault.url == url {
                self.servers.insert(serverInfo(url: url, key: ""), at: 0)
            }else{
                self.servers.append(serverInfo(url: url, key: ""))
            }
            toastText = NSLocalizedString("addSuccess",comment: "")
        }else{
            toastText =  NSLocalizedString("serverExist",comment: "")
            return (false,toastText)
        }
        
        Task(priority: .userInitiated) {
            await self.registerAll()
        }
        
        return (true,toastText)
    }
    
    
    
    func registerAll() async {
        for server in servers{
            await register(server: server)
        }
    }
    
    
    func register(server: serverInfo) async  {
        
        guard let index = servers.firstIndex(where: {$0.id == server.id}) else {
#if DEBUG
            print("没有获取到")
#endif
        
            return
        }
        
        do {
            if let deviceInfo:DeviceInfo? = try await NetworkManager.shared.fetch(url: server.url + "/register/" + self.deviceToken + "/" + servers[index].key){
                
                dispatch_sync_safely_main_queue {
                    servers[index].key = deviceInfo?.pawKey ?? ""
#if DEBUG
                    print("注册设备: \(String(describing: deviceInfo))")
#endif
                }
            }
            
            
        }catch{
#if DEBUG
            print(error)
#endif
           
        }
        
    }
    
    func openSetting(){
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        UIApplication.shared.open(settingsURL)
    }
}


extension MainManager{
    func addQuickActions(){
        UIApplication.shared.shortcutItems = QuickAction.allShortcutItems
    }
   
    
   
}


extension MainManager{
    func healthAllColor() async-> Color{
        let servers = self.servers
        var hasTrue = false
        var hasFalse = false
        
        for server in servers {
            let ok = await health(url: server.url + "/health")
            if ok {
                hasTrue = true
                if let index = servers.firstIndex(where: {$0.id == server.id}){
                    dispatch_sync_safely_main_queue {
                        self.servers[index].status = true
                    }
                }
            } else {
                hasFalse = true
                if let index = servers.firstIndex(where: {$0.id == server.id}){
                    dispatch_sync_safely_main_queue {
                        self.servers[index].status = false
                    }
                }
            }
        }
        
        if hasTrue && hasFalse {
            return .orange
        } else if hasTrue {
            return .green
        } else {
            return .red
        }
        
    }
}
