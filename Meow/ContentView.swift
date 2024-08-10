//
//  ContentView.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    
    @StateObject private var monitor = Monitors()
    
    @StateObject private var router = RouterManager.shared
    
    @ObservedResults(Message.self) var messages
    
    @State var toastText:String = ""
    
    var readCount:Int{
        messages.where({!$0.read}).count
    }
    
    var body: some View {
        TabView(selection: $router.page) {
            // MARK: 示例页面
            NavigationStack{
                ExampleView()
                    .navigationTitle(NSLocalizedString("useExample",comment: ""))
            }
            .tag(TabPage.example)
            .tabItem {
                Label(NSLocalizedString("bottomBarExample",comment: ""), systemImage: "chair.lounge")
            }
            
            // MARK: 信息页面
            NavigationStack{
               MessagesView()
                    .navigationTitle(NSLocalizedString("bottomBarMsg",comment: ""))
            }
            .tag(TabPage.message)
            .badge(readCount)
            .tabItem {
                Label(NSLocalizedString("bottomBarMsg",comment: ""), systemImage: "ellipsis.message")
            }
            
            // MARK: 设置页面
            NavigationStack{
                SettingsView()
                    .navigationTitle(NSLocalizedString("bottomBarSettings",comment: ""))
            }
           
            .tabItem {
                Label(NSLocalizedString("bottomBarSettings",comment: ""), systemImage: "gearshape")
            }
            .tag(TabPage.setting)
            
            
        }
        .sheet(isPresented: router.sheetPageShow){
            switch RouterManager.shared.sheetPage {
            case .servers:
                ServersView(showClose: true)
            case .appIcon:
                NavigationStack{
                    AppIconView()
                }.presentationDetents([.medium])
            case .web:
                SFSafariView(url: RouterManager.shared.webUrl)
                    .ignoresSafeArea()
            default:
                EmptyView()
            }
        }
        
        // MARK: full
        .fullScreenCover(isPresented: router.fullPageShow){
            switch router.fullPage {
            case .login:
                ChangeKeyWithEmailView()
            case .servers:
                ServersView(showClose: true)
            case .music:
                RingtongView()
            case .scan:
                ScanView { code in
                    let (_,msg) = MainManager.shared.addServer(url: code)
                    self.toastText = msg
                }
            case .web:
                SFSafariViewWrapper(url: router.webUrl)
                    .ignoresSafeArea()
            case .issues:
                SFSafariViewWrapper(url: router.webUrl)
                    .ignoresSafeArea()
            default:
                EmptyView()
            }
        }
        .toast(info: $toastText)
      
    }
}

#Preview {
    ContentView()
}
