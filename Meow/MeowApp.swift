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
    @AppStorage("start_first_pahe") var firstStartShow:Bool = true
	@StateObject private var realm = RealmManager.shared
	@StateObject private var manager = MainManager.shared
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                ContentView()
                if firstStartShow{
                    StartPageHelpView(show: $firstStartShow)
                }
                
            }
			.environmentObject(realm)
			.environmentObject(manager)
			.modelContainer(for: ImageItem.self)
        }
		
    }
}
