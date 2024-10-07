//
//  SettingsView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import RealmSwift
import Combine

let ISPAD = UIDevice.current.userInterfaceIdiom == .pad

struct SettingsView: View {
	@ObservedResults(Message.self) var messages
	@EnvironmentObject private var manager:MainManager
	@EnvironmentObject private var realm:RealmManager
	
	@State private var isArchive:Bool = false
	@State private var webShow:Bool = false
	@State private var webUrl:String = otherUrl.helpWebUrl
	@State private var progressValue: Double = 0.0
	@State private var toastText = ""
	@State private var isShareSheetPresented = false
	@State private var jsonFileUrl:URL?
	@State private var cloudStatus = NSLocalizedString("checkimge",comment: "")
	@State private var serverSize:CGSize = .zero
	@State private var serverColor:Color = .red
	@State private var errorAnimate1:Bool = false
	@State private var errorAnimate2:Bool = false
	@State private var errorAnimate3:Bool = false
	@State private var showLoading:Bool = false
	
	
	
	@StateObject private var router = RouterManager.shared
	@StateObject private var toolsManager = ToolsManager.shared
	@AppStorage(BaseConfig.activeAppIcon) var setting_active_app_icon:appIcon = .def
	
	@State private var document = TextDocument(text: "123")
	
	@State private var timerz: AnyCancellable?
	
	@State var valueToUse: Int = 0
	
	
	var body: some View {
		
		VStack{
			List{
				
				if ISPAD{
					NavigationLink{
						MessagesView()
							.navigationTitle(NSLocalizedString("bottomBarMsg",comment: ""))
					}label: {
						Label(NSLocalizedString("bottomBarMsg",comment: ""), systemImage: "app.badge")
					}
					
				}
				
				
				Section(header:Text(NSLocalizedString("exportHeader",comment: ""))) {
					Button{
						self.showLoading = true
						realm.exportFiles(messages){url, text in
							if let url{
								self.jsonFileUrl = url
								self.isShareSheetPresented = true
							}
							self.showLoading = false
						}
					}label:{
						HStack{
							Label(NSLocalizedString("exportTitle",comment: ""), systemImage: "square.and.arrow.up.circle")
							
							Spacer()
							Text(String(format: NSLocalizedString("someMessageCount",comment: ""), messages.count) )
						}
					}
					
					
				}
				
				
				
				Section(footer:Text(NSLocalizedString("deviceTokenHeader",comment: ""))) {
					Button{
						if manager.deviceToken != ""{
							manager.copy(text:manager.deviceToken)
							self.toastText = NSLocalizedString("copySuccessText", comment: "")
							
						}else{
							self.toastText = NSLocalizedString("needRegister", comment: "")
						}
					}label: {
						HStack{
							
							Label {
								Text(ISPAD ? "Token" : "DeviceToken")
									.font(.system(size: 15))
									.lineLimit(1)
									.foregroundStyle(.lightDark)
							} icon: {
								Image(systemName: "key.radiowaves.forward")
									.scaleEffect(0.9)
							}
							
							
							Spacer()
							Text(maskString(manager.deviceToken))
								.foregroundStyle(.gray)
							Image(systemName: "doc.on.doc")
								.scaleEffect(0.9)
						}
					}
				}
				
				Section {
					Toggle(isOn: $toolsManager.archive) {
						Text(NSLocalizedString("defaultSave", comment: "默认保存"))
					}
				}footer:{
					Text(NSLocalizedString("archiveNote", comment: ""))
						.foregroundStyle(.gray)
				}
				
				
				
				
				Section {
					
					NavigationLink {
						MainImageCacheView()
							.toolbar(.hidden, for: .tabBar)
							.navigationTitle(NSLocalizedString("historyImage", comment: "历史图片"))
						
					} label: {
						Label(NSLocalizedString("historyImage", comment: "历史图片"), systemImage: "photo.on.rectangle")
					}
					
					
				}header :{
					Text(NSLocalizedString("historyImage", comment: "历史图片"))
						.foregroundStyle(.gray)
				}
				
				
				
				
				
				Section(header: Text(NSLocalizedString("configTitle", comment: "配置"))) {
					Button{
						RouterManager.shared.sheetPage = .appIcon
					}label: {
						
						
						HStack(alignment:.center){
							Label {
								Text(NSLocalizedString("AppIconTitle",comment: "程序图标"))
									.foregroundStyle(.lightDark)
							} icon: {
								Image(setting_active_app_icon.logo)
									.resizable()
									.scaledToFit()
									.frame(width: 25)
									.clipShape(RoundedRectangle(cornerRadius: 10))
									.scaleEffect(0.9)
							}
							Spacer()
							Image(systemName: "chevron.right")
								.foregroundStyle(.gray)
						}
						
					}
					
					
					Picker(selection: toolsManager.$badgeMode) {
						Text(NSLocalizedString("badgeAuto",comment: "自动")).tag(badgeAutoMode.auto)
						Text(NSLocalizedString("badgeCustom",comment: "自定义")).tag(badgeAutoMode.custom)
					} label: {
						Label {
							Text(NSLocalizedString("badgeModeTitle",comment: "角标模式"))
						} icon: {
							Image(systemName: "app.badge")
								.scaleEffect(0.9)
						}
					}
					.onChange(of: toolsManager.badgeMode) {_ ,value in
						
						toolsManager.badge = value == .auto ?  realm.NReadCount() : -1
						
					}
					
					
					
					NavigationLink(destination:
									EmailPageView() .toolbar(.hidden, for: .tabBar)
					) {
						
						Label {
							Text(NSLocalizedString("mailTitle", comment: "自动化配置"))
						} icon: {
							Image(systemName: "paperclip")
								.scaleEffect(0.9)
						}
					}
					
					
					NavigationLink(destination:
									CryptoConfigView()
						.toolbar(.hidden, for: .tabBar)
					) {
						
						
						Label {
							Text(NSLocalizedString("cryptoConfigNavTitle", comment: "算法配置") )
						} icon: {
							Image(systemName: "bolt.shield")
								.scaleEffect(0.9)
						}
					}
					
					NavigationLink{
						RingtongView()
					}label: {
						
						HStack{
							Label {
								Text(NSLocalizedString("musicConfigList", comment: "铃声列表") )
							} icon: {
								Image(systemName: "headphones.circle")
									.scaleEffect(0.9)
							}
							Spacer()
							Text(toolsManager.sound)
								.scaleEffect(0.9)
								.foregroundStyle(.gray)
						}
					}
					
					
				}
				
				
				Section(header:Text(NSLocalizedString("otherHeader",comment: ""))) {
					
					
					Button{
						manager.openSetting()
					}label: {
						HStack(alignment:.center){
							
							Label {
								Text(NSLocalizedString("openSetting",comment: ""))
									.foregroundStyle(.lightDark)
							} icon: {
								Image(systemName: "gearshape")
									.scaleEffect(0.9)
								
							}
							
							Spacer()
							Image(systemName: "chevron.right")
								.foregroundStyle(.gray)
						}
						
					}
					
					Button{
						RouterManager.shared.fullPage = .web
						RouterManager.shared.webUrl =  otherUrl.problemWebUrl
						
					}label: {
						HStack(alignment:.center){
							Label {
								Text(NSLocalizedString("commonProblem",comment: ""))
									.foregroundStyle(.lightDark)
							} icon: {
								Image(systemName: "questionmark.circle")
									.scaleEffect(0.9)
							}
							
							Spacer()
							Image(systemName: "chevron.right")
								.foregroundStyle(.gray)
						}
						
					}
					
					Button{
						RouterManager.shared.webUrl = otherUrl.helpWebUrl
						RouterManager.shared.fullPage = .web
						
					}label: {
						HStack(alignment:.center){
							Label {
								Text(NSLocalizedString("useHelpTitle",comment: ""))
									.foregroundStyle(.lightDark)
							} icon: {
								Image(systemName: "person.crop.circle.badge.questionmark")
									.scaleEffect(0.9)
							}
							
							Spacer()
							Image(systemName: "chevron.right")
								.foregroundStyle(.gray)
						}
						
						
					}
					
					
				}
				
				
			}.listStyle(.insetGrouped)
			
			
		}
		.loading(showLoading)
		.alert(info: $toastText)
		.background(Color(hex: "#f5f5f5"))
		.tipsToolbar(wifi: Monitors.shared.isConnected, notification: Monitors.shared.isAuthorized, callback: {
			manager.openSetting()
		})
		.toolbar {
			
			ToolbarItem {
				
				Button {
					RouterManager.shared.showServerListView.toggle()
				} label: {
					Image(systemName: "externaldrive.badge.wifi")
						.foregroundStyle(serverColor)
				}
				
			}
			
			
			
			
		}
		
		
		.sheet(isPresented: $isShareSheetPresented) {
			ShareSheet(fileUrl: jsonFileUrl!)
				.presentationDetents([.medium, .large])
		}
		.onAppear {
			
			DispatchQueue.global().async {
				Task{
					let color = await manager.healthAllColor()
					await MainActor.run{
						self.serverColor = color
					}
					
				}
			}
		}
		.navigationDestination(isPresented: $router.showServerListView) {
			ServersView()
				.toolbar(.hidden, for: .tabBar)
		}
		
		
		
		
		
	}
	
}

extension SettingsView{
	func maskString(_ str: String) -> String {
		guard str.count > 6 else {
			return str
		}
		
		let start = str.prefix(3)
		let end = str.suffix(4)
		let masked = String(repeating: "*", count: 5) // 固定为5个星号
		
		return start + masked + end
	}
	
	
	
}


#Preview {
	NavigationStack{
		SettingsView()
	}
	
}
