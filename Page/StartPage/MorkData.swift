//
//  MorkData.swift
//  Meow
//
//  Created by He Cho on 2024/8/25.
//

import UIKit
import SwiftUI

struct PageData {
    let title: String
    let header: String
    let content: String
    let imageName: String
    let color: Color
    let textColor: Color
}

struct MockData {
    static let pages: [PageData] = [
        PageData(
            title:  NSLocalizedString("firstStartTitle", comment: "允许必要的权限"),
            header:  NSLocalizedString("firstStartHeader", comment: "Step 1"),
            content:  NSLocalizedString("firstStartContent", comment: "没有通知权限,App将不能运行"),
            imageName: "notification",
            color: Color(hex: "F38181"),
            textColor: Color(hex: "FFFFFF")),
        PageData(
            title:  NSLocalizedString("firstStartTitle1", comment:  "多种发推方式"),
            header:  NSLocalizedString("firstStartHeader1", comment: "Step 2"),
            content:  NSLocalizedString("firstStartContent1", comment: "最简单的直接浏览器输入url调用，也可以使用任何已知的程序脚本"),
            imageName: "safari",
            color: Color(hex: "FCE38A"),
            textColor: Color(hex: "4A4A4A")),
        PageData(
            title: NSLocalizedString("firstStartTitle2", comment:  "实现自动化"),
            header: NSLocalizedString("firstStartHeader2", comment: "Step 3"),
            content:  NSLocalizedString("firstStartContent2", comment: "配合邮件配置，实现收到消息自动执行某种功能"),
            imageName: "kuaijie",
            color: Color(hex: "95E1D3"),
            textColor: Color(hex: "4A4A4A")),
        PageData(
            title:  NSLocalizedString("firstStartTitle3", comment:  "私有服务器支持"),
            header:  NSLocalizedString("firstStartHeader3", comment: "Step 4"),
            content:  NSLocalizedString("firstStartContent3", comment: "自定义服务器，让消息传递更安全！"),
            imageName: "servers",
            color: Color(hex: "EAFFD0"),
            textColor: Color(hex: "4A4A4A")),
    ]
}

/// Color converter from hex string to SwiftUI's Color
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(red: Double(r) / 0xff, green: Double(g) / 0xff, blue: Double(b) / 0xff)
    }
}
