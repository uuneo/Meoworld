//
//  AppDelegate.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import UIKit


struct Identifiers {
    static let reminderCategory = "myNotificationCategory"
    static let cancelAction = "cancel"
    static let copyAction = "copy"
}


class AppDelegate: NSObject, UIApplicationDelegate{
    
    let generator = UISelectionFeedbackGenerator()
    
    func setupRealm() {
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = kRealmDefaultConfiguration
        
        
#if DEBUG
        let realm = try? Realm()
        debugPrint("message count: \(realm?.objects(Message.self).count ?? 0)")
#endif
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        // MARK: 将设备令牌发送到服务器
#if DEBUG
        debugPrint("设备令牌:",token)
#endif
        
        MainManager.shared.deviceToken = token
        // MARK: 注册设备
        Task{
           await MainManager.shared.registerAll()
        }
        
    }
    

    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // MARK:  处理注册失败的情况
#if DEBUG
        debugPrint(error)
#endif
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        
        // 必须在应用一开始就配置，否则应用可能提前在配置之前试用了 Realm() ，则会创建两个独立数据库。
        setupRealm()
        
        
        UNUserNotificationCenter.current().delegate = self
        
        
        let copyAction =  UNNotificationAction(identifier:Identifiers.copyAction, title: NSLocalizedString("copyTitle",comment: ""), options: [],icon: .init(systemImageName: "doc.on.doc"))
        
        // 创建 category
        let category = UNNotificationCategory(identifier: Identifiers.reminderCategory,
                                              actions: [copyAction],
                                              intentIdentifiers: [],
                                              options: [.hiddenPreviewsShowTitle])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
        
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let selectAction = options.shortcutItem{
            QuickAction.selectAction = selectAction
        }
        let sceneonfiguration = UISceneConfiguration(name: "Quick Action Scene", sessionRole: connectingSceneSession.role)
        sceneonfiguration.delegateClass = QuickActionSceneDelegate.self
        return sceneonfiguration
    }
    
    
    
   
    

    

    
    
    /// 停止响铃
    func stopCallNotificationProcessor() {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(BaseConfig.kStopCallProcessorKey as CFString), nil, nil, true)
    }
    
    
    
    
    
    
    
}


class QuickActionSceneDelegate:UIResponder,UIWindowSceneDelegate{
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        QuickAction.selectAction = shortcutItem
    }
}



extension AppDelegate :UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notificatonHandler(userInfo: response.notification.request.content.userInfo)
        RouterManager.shared.page = .message
        RouterManager.shared.fullPage = .none
        completionHandler()
    }
    
    // 处理应用程序在前台是否显示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        notificatonHandler(userInfo: notification.request.content.userInfo)
        
        generator.prepare()
        generator.selectionChanged()
        
        
        completionHandler(.badge)
        
    }
    
    
    private func notificatonHandler(userInfo: [AnyHashable: Any]) {
        let url: URL? = {
            if let url = userInfo["url"] as? String {
                return URL(string: url)
            }
            return nil
        }()
        
        // URL 直接打开
        if let url = url {
            MainManager.shared.openUrl(url: url)
            return
        }
        
        
        if UIApplication.shared.applicationState == .active {
            stopCallNotificationProcessor()
        }
       
        
        
    }

}

