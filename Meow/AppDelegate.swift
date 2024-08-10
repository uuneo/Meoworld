//
//  AppDelegate.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import Foundation
import UIKit
import RealmSwift


struct Identifiers {
    static let reminderCategory = "myNotificationCategory"
    static let cancelAction = "cancel"
    static let copyAction = "copy"
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate{
    
    
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
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        notificatonHandler(userInfo: response.notification.request.content.userInfo)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if UIApplication.shared.applicationState == .active {
            stopCallNotificationProcessor()
        }
        return .sound
    }
    
    private func notificatonHandler(userInfo: [AnyHashable: Any]) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // 后台进入前台
        // bark 同步服务器数据
        // ServerManager.shared.syncAllServers()
        // 暂时不知道意图，以后再说
        
        // 设置 -1 可以清除应用角标，但不清除通知中心的推送
        // 设置 0 会将通知中心的所有推送一起清空掉
        UIApplication.shared.applicationIconBadgeNumber = -1
        // 如果有响铃通知，则关闭响铃
        stopCallNotificationProcessor()
    }
    
    
    
    /// 停止响铃
    func stopCallNotificationProcessor() {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(BaseConfig.kStopCallProcessorKey as CFString), nil, nil, true)
    }
    
    
    
    
    
    
    
}
