//
//  ContentView.swift
//  Meow
//
//  Created by He Cho on 2024/8/8.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
	@EnvironmentObject private var realm:RealmManager
	@EnvironmentObject private var manager:MainManager
	@Environment(\.scenePhase) var scenePhase
	@StateObject private var monitor = Monitors()
	
	@StateObject private var router = RouterManager.shared
	@AppStorage("first_start",store: defaultStore) var firstStart:Bool = true
	
	@State private var noShow:NavigationSplitViewVisibility = .detailOnly
	
	@ObservedResults(Message.self) var messages
	
	@State private var toastText:String = ""
	
	@State private  var showAlart:Bool = false
	@State private  var activeName:String = ""
	
	var readCount:Int{
		messages.where({!$0.read}).count
	}
	
	var body: some View {
		
		Group{
			if ISPAD{
				IpadHomeView()
			}else{
				IphoneHomeView()
			}
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
					let (_,msg) = manager.addServer(url: code)
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
		.alert(info: $toastText)
		.onAppear{
			if firstStart {
				realm.write(messages: Message.messages)
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
							
							realm.delete(read: activeName == "alldelnotread")
							
							self.toastText = NSLocalizedString("controlSuccess", comment:"操作成功")
							
						}
					), secondaryButton: .cancel())
		}
		.onOpenURL { url in
			
			guard let scheme = url.scheme,
				  let host = url.host(),
				  let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else{ return }
			
			let params = components.getParams()
			let router = RouterManager.shared
#if DEBUG
			debugPrint(scheme, host, params)
#endif
			
			
			if host == "login"{
				if let url = params["url"]{
					
					router.scanUrl = url
					router.fullPage = .login
					
				}else{
					self.toastText =  NSLocalizedString("paramsError", comment: "参数错误")
				}
				
			}else if host == "add"{
				if let url = params["url"]{
					let (mode1,msg) = manager.addServer(url: url)
#if DEBUG
					debugPrint(mode1)
#endif
					
					self.toastText = msg
					
					if !router.showServerListView {
						router.fullPage = .none
						router.sheetPage = .none
						router.page = .setting
						router.showServerListView = true
					}
				}else{
					
					self.toastText = NSLocalizedString("paramsError", comment:"参数错误")
				}
			}
			
		}
		
	}
	
	
	@ViewBuilder
	func IphoneHomeView()-> some View{
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
	}
	
	@ViewBuilder
	func IpadHomeView() -> some View{
		NavigationSplitView(columnVisibility: $noShow) {
			SettingsView()
				.navigationTitle(NSLocalizedString("bottomBarSettings",comment: ""))
		} detail: {
			NavigationStack{
				MessagesView()
					.navigationTitle(NSLocalizedString("bottomBarMsg",comment: ""))
				
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
					realm.readMessage()
					
					self.toastText = NSLocalizedString("controlSuccess", comment:"操作成功")
				case "alldelread","alldelnotread":
					self.activeName = name
					self.showAlart.toggle()
				default:
					break
				}
			}
			
			HapticsManager.shared.restartEngine()
		case .background:
			manager.addQuickActions()
			HapticsManager.shared.stopEngine()
			
		default:
			
			break
			
		}
		
		let toolManager = ToolsManager.shared
		
		if toolManager.badgeMode == .auto{
			toolManager.changeBadge(badge: realm.NReadCount())
		}else{
			toolManager.changeBadge(badge: -1)
		}
		
	}
}

#Preview {
	ContentView()
}
