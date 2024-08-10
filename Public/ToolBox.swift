//
//  ToolBox.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation
import SwiftUI

/// 将代码安全的运行在主线程
func dispatch_sync_safely_main_queue(_ block: () -> ()) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}


struct CirclePreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct markDownPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
