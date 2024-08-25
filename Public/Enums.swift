//
//  Enums.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation
import UIKit

enum SubPage{
    case login
    case servers
    case scan
    case music
    case appIcon
    case web
    case issues
    case none
}


enum TabPage :String{
    case message = "message"
    case setting = "setting"
}




enum appIcon:String,CaseIterable{
    case def = "AppIcon"
    case zero = "AppIcon0"
    case one = "AppIcon1"
   
    
    static let arr = [appIcon.def,appIcon.zero,appIcon.one]
    
    var toLogoImage: String{
        switch self {
        case .def:
            logoImage.def.rawValue
        case .zero:
            logoImage.zero.rawValue
        case .one:
            logoImage.one.rawValue
      
        }
    }
}


enum logoImage:String,CaseIterable{
    case def = "logo"
    case zero = "logo0"
    case one = "logo1"
    static let arr = [logoImage.def,logoImage.zero,logoImage.one]
    
}



enum badgeAutoMode:String, CaseIterable {
    case auto = "Auto"
    case custom = "Custom"
}


enum saveType:String{
    case failUrl
    case failSave
    case failAuth
    case success
    case other
}

extension saveType {

    var localized: String {
        switch self {
        case .failUrl:
            return NSLocalizedString(self.rawValue, comment: "Url错误")
        case .failSave:
            return NSLocalizedString("failSave", comment: "Save failed")
        case .failAuth:
            return NSLocalizedString("failAuth", comment: "No permission")
        case .success:
            return NSLocalizedString("saveSuccess", comment: "Save successful")
        case .other:
            return NSLocalizedString("failOther", comment: "Other error")
        }
    }
}



enum MessageGroup:String{
    case group = "分组"
    case all = "全部"
}
enum mesAction: String{
    case markRead = "全部标为已读"
    case lastHour = "一小时前"
    case lastDay = "一天前"
    case lastWeek = "一周前"
    case lastMonth = "一月前"
    case allTime = "所有时间"
}

enum requestHeader :String {
    case https = "https://"
    case http = "http://"
}


enum QuickAction{
    static var selectAction:UIApplicationShortcutItem?
    
    static var allReaduserInfo:[String: NSSecureCoding]{
        ["name":"allread" as NSSecureCoding]
    }
    
    static var allDelReaduserInfo:[String: NSSecureCoding]{
        ["name":"alldelread" as NSSecureCoding]
    }
    
    static var allDelNotReaduserInfo:[String: NSSecureCoding]{
        ["name":"alldelnotread" as NSSecureCoding]
    }
    
    static var allShortcutItems = [
        UIApplicationShortcutItem(
            type: "allread",
            localizedTitle: NSLocalizedString("readAllQuickAction", comment: "已读全部") ,
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(systemImageName: "bookmark"),
            userInfo: allReaduserInfo
        ),
        UIApplicationShortcutItem(
            type: "alldelread",
            localizedTitle: NSLocalizedString("delReadAllQuickAction", comment: "删除全部已读"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(systemImageName: "trash"),
            userInfo: allDelReaduserInfo
        ),
        UIApplicationShortcutItem(
            type: "alldelnotread",
            localizedTitle: NSLocalizedString("delNotReadAllQuickAction", comment: "删除全部未读"),
            localizedSubtitle: "",
            icon: UIApplicationShortcutIcon(systemImageName: "trash"),
            userInfo: allDelNotReaduserInfo
        )
    ]
}
