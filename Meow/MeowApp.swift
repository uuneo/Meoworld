//
//  MeowApp.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import SwiftUI


@main
struct MeowApp: SwiftUI.App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
       
    }
}
