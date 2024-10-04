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




enum appIcon:String, CaseIterable,Equatable{
    case def = "AppIcon"
    case zero = "AppIcon0"
    case one = "AppIcon1"
    case two = "AppIcon2"
    
    var logo: String{
        switch self {
        case .def:
			"logo"
        case .zero:
			"logo0"
        case .one:
			"logo1"
		case .two:
			"logo2"
        }
    }
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




enum mesAction: String, CaseIterable, Equatable{
    case markRead = "allMarkRead"
    case lastHour = "hourAgo"
    case lastDay = "dayAgo"
    case lastWeek = "weekAgo"
    case lastMonth = "monthAgo"
    case allTime = "allTime"
	case cancel = "cancel"
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

struct Identifiers {
    static let reminderCategory = "myNotificationCategory"
    static let cancelAction = "cancel"
    static let copyAction = "copy"
    static let detailAction = "viewDetail"
}
