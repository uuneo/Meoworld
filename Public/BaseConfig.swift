//
//  BaseConfig.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

@_exported import RealmSwift
import Foundation
import UIKit

let defaultStore = UserDefaults(suiteName: BaseConfig.groupName)

let kRealmDefaultConfiguration = {
    let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: BaseConfig.groupName)
    
    let fileUrl = groupUrl?.appendingPathComponent(BaseConfig.realmName)
    
    let config = Realm.Configuration(
        fileURL: fileUrl,
        schemaVersion: BaseConfig.realmModalVersion,
        migrationBlock: { _, oldSchemaVersion in
            // We haven’t migrated anything yet, so oldSchemaVersion == 0
            if oldSchemaVersion < 1 {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        }
    )
    return config
}()



struct otherUrl {
#if DEBUG
    static let defaultServer = "https://dev.twown.com"
#else
    static let defaultServer = "https://push.twown.com"
#endif
    static let docServer = "https://alarmpaw.twown.com"
    static let defaultImage = docServer + "/_media/avatar.jpg"
    static let helpWebUrl = docServer + "/#/tutorial"
    static let problemWebUrl = docServer + "/#/faq"
    static let delpoydoc = docServer + "/#/?id=alarmpaw"
    static let emailHelpUrl = docServer + "/#/email"
    static let helpRegisterWebUrl = docServer + "/#/registerUser"
    static let actinsRunUrl = "https://github.com/96bit/AlarmPaw/actions/runs/"
    static let musicUrl = "https://convertio.co/mp3-caf/"
    static let callback = defaultServer + "/callback"
    static let issues = "https://github.com/uuneo/MeowWorld/issues/new"
}






struct BaseConfig {
    
    static let  groupName = "group.Meoworld"
    static let  cloudMessageName = "MeowMessageCloud"
    static let  settingName = "cryptoSettingFields"
    static let  deviceToken = "deviceToken"
    static let  voipDeviceToken = "voipDeviceToken"
    static let  imageCache = "shard"
    static let  badgemode = "Meowbadgemode"
    static let  server = "serverArrayStroage"
    static let  defaultPage = "defaultPageViewShow"
    static let  messageFirstShow = "messageFirstShow"
    static let  messageShowMode = "messageShowMode"
    static let  syncServerUrl = "syncServerUrl"
    static let  syncServerParams = "syncServerParams"
    static let  emailConfig = "emailStmpConfig"
    static let  firstStartApp = "firstStartApp"
    static let  CryptoSettingFields = "CryptoSettingFields"
    static let  recordType = "NotificationMessage"
    static let  realmName = "Meowrld.realm"
    static let  kStopCallProcessorKey = "stopCallProcessorNotification"
    static let  Sounds = "Sounds"
    static let  archiveName = "meowArchive"
    static let  realmModalVersion:UInt64 = 2
    static let  defaultSound = "defaultSound"
    static let  activeAppIcon = "setting_active_app_icon"
    

}



