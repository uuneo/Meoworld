//
//  ContentView.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import SwiftUI
import RealmSwift
import Shiny

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var monitor = Monitors()
    
    @StateObject private var router = RouterManager.shared
    @AppStorage("first_start",store: defaultStore) var firstStart:Bool = true
    
    
    
    @ObservedResults(Message.self) var messages
    
    @State private var toastText:String = ""
    
    @State private  var showAlart:Bool = false
    @State private  var activeName:String = ""
    
    var readCount:Int{
        messages.where({!$0.read}).count
    }
    
    var body: some View {
        TabView(selection: $router.page) {
            
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
            case .contactMe:
                ChatDemo()
            default:
                EmptyView()
            }
        }
        .toast(info: $toastText)
        .onAppear{
            if firstStart {
                for item in Message.messages{
                    let _ = RealmManager.shared.addObject(item)
                }
                self.firstStart = false
            }
        }
        .onChange(of: scenePhase) { newPhase in
            
            self.backgroundModeHandler(of: newPhase)
           
            
        }
        .alert(isPresented: $showAlart) {
            Alert(title:
                    Text(NSLocalizedString("changeTipsTitle", comment: "操作不可逆！")),
                  message:
                    Text( activeName == "alldelnotread" ?
                          NSLocalizedString("changeTips1SubTitle", comment: "是否确认删除所有未读消息!") : NSLocalizedString("changeTips2SubTitle", comment: "是否确认删除所有已读消息!")
                        ),
                  primaryButton:
                    .destructive(
                        Text(NSLocalizedString("deleteTitle", comment: "删除")),
                        action: {
                            RealmManager.shared.allDel( activeName == "alldelnotread" ? 1 : 0)
                            
                            self.toastText = NSLocalizedString("controlSuccess", comment:"操作成功")
                           
                        }
                    ), secondaryButton: .cancel())
        }
        .onOpenURL { url in
            
            guard let scheme = url.scheme,
                  let host = url.host(),
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else{ return }
            let params = components.getParams()
#if DEBUG
            debugPrint(scheme, host, params)
#endif
            
            
            if host == "login"{
                if let url = params["url"]{
                    
                    RouterManager.shared.scanUrl = url
                    RouterManager.shared.fullPage = .login
                    
                }else{
                    self.toastText =  NSLocalizedString("paramsError", comment: "参数错误")
                }
                
            }else if host == "add"{
                if let url = params["url"]{
                    let (mode1,msg) = MainManager.shared.addServer(url: url)
#if DEBUG
                    debugPrint(mode1)
#endif
                    
                    self.toastText = msg
                    if !RouterManager.shared.showServerListView {
                        RouterManager.shared.fullPage = .none
                        RouterManager.shared.sheetPage = .none
                        RouterManager.shared.page = .setting
                        RouterManager.shared.showServerListView = true
                    }
                }else{
                    
                    self.toastText = NSLocalizedString("paramsError", comment:"参数错误")
                }
            }
            
        }
      
    }
}

extension ContentView{
    func backgroundModeHandler(of value:ScenePhase){
        switch value{
        case .active:
#if DEBUG
            print("app active")
#endif
            AudioPlayerManager.stopCallNotificationProcessor()
            
            if let name = QuickAction.selectAction?.userInfo?["name"] as? String{
                QuickAction.selectAction = nil
#if DEBUG
                print(name)
#endif
                
                RouterManager.shared.page = .message
                switch name{
                case "allread":
                    RealmManager.shared.allRead()
                    self.toastText = NSLocalizedString("controlSuccess", comment:"操作成功")
                case "alldelread","alldelnotread":
                    self.activeName = name
                    self.showAlart.toggle()
                default:
                    break
                }
            }
        case .background:
            MainManager.shared.addQuickActions()
            
        default:
            break
            
        }
        
        if ToolsManager.shared.badgeMode == .auto{
            ToolsManager.shared.changeBadge(badge: RealmManager.shared.getUnreadCount() ?? -1)
        }else{
            ToolsManager.shared.changeBadge(badge: -1)
        }
       
    }
}

#Preview {
    ContentView()
}
