//
//  SettingsView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import RealmSwift
import Combine

struct SettingsView: View {
    @ObservedResults(Message.self) var messages
    
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
    @StateObject private var manager = MainManager.shared
    @StateObject private var router = RouterManager.shared
    @StateObject private var toolsManager = ToolsManager.shared
    @AppStorage(BaseConfig.activeAppIcon) var setting_active_app_icon:appIcon = .def
    
    @State private var document = TextDocument(text: "123")
    
    @State private var timerz: AnyCancellable?
    
    var body: some View {
        
        VStack{
            List{
                
                
                
                Section(header:Text(NSLocalizedString("exportHeader",comment: ""))) {
                    HStack{
        
                        Button {
                            
                            if RealmManager.shared.getObject()?.count ?? 0 > 0{
                                self.showLoading = true
                                self.exportFiles()
                               
                            }else{
                                self.toastText = NSLocalizedString("nothingMessage", comment: "")
                                self.showLoading = false
                            }
                            
                            
                        } label: {
                            
                            Label {
                                Text(NSLocalizedString("exportTitle",comment: ""))
                            } icon: {
                                Image(systemName: "square.and.arrow.up")
                                    .scaleEffect(0.9)
                            }
                            
                            
                            
                            
                            
                            
                        }
                        
                        Spacer()
                        Text(String(format: NSLocalizedString("someMessageCount",comment: ""), messages.count) )
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
                                Text("DeviceToken")
                                    .font(.system(size: 15))
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
                
                Section(header: Text(NSLocalizedString("configTitle", comment: "配置"))) {
                    Button{
                        RouterManager.shared.sheetPage = .appIcon
                    }label: {
                        
                        
                        HStack(alignment:.center){
                            Label {
                                Text(NSLocalizedString("AppIconTitle",comment: "程序图标"))
                                    .foregroundStyle(.lightDark)
                            } icon: {
                                Image(setting_active_app_icon.toLogoImage)
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
                    .onChange(of: toolsManager.badgeMode) {value in
                        if value == .auto{
                            if let badge = RealmManager.shared.getUnreadCount(){
                                ToolsManager.shared.changeBadge(badge:badge )
                            }
                        }else{
                            ToolsManager.shared.changeBadge(badge: -1)
                        }
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
                    
                    
                    NavigationLink {
                        ChatDemo()
                            .toolbar(.hidden, for: .tabBar)
                            
                    } label: {
                        Label {
                            Text(NSLocalizedString("contactMe",comment: ""))
                                .foregroundStyle(.lightDark)
                        } icon: {
                            Image(systemName: "questionmark.circle")
                                .scaleEffect(0.9)
                        }
                    }

                    
                }
                
                
            }.listStyle(.insetGrouped)
            
            
        }
        .loading(showLoading)
        .toast(info: $toastText)
        .background(hexColor("#f5f5f5"))
        .toolbar {
            
            Group{
                
                if !Monitors.shared.isConnected && Monitors.shared.isAuthorized{
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            manager.openSetting()
                        } label: {
                            Image(systemName: "wifi.exclamationmark")
                                .foregroundStyle(.yellow)
                                .opacity(errorAnimate1 ? 1 : 0.1)
                                .onAppear{
                                    withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                        self.errorAnimate1 = true
                                    }
                                }
                                .onDisappear{
                                    self.errorAnimate1 = false
                                }
                            
                        }
                        
                    }
                }
                
                if !Monitors.shared.isAuthorized && Monitors.shared.isConnected {
                    
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            manager.openSetting()
                        } label: {
                            Image(systemName: "bell.slash")
                                .foregroundStyle(.red)
                                .opacity(errorAnimate2 ? 0.1 : 1)
                                .onAppear{
                                    withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                        self.errorAnimate2 = true
                                    }
                                }
                                .onDisappear{
                                    self.errorAnimate2 = false
                                }
                            
                        }
                        
                    }
                    
                    
                }
                
                if !Monitors.shared.isAuthorized && !Monitors.shared.isConnected  {
                    
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            manager.openSetting()
                        } label: {
                            
                            ZStack{
                                
                                Image(systemName: "bell.slash")
                                    .foregroundStyle(.red)
                                    .opacity(errorAnimate3 ? 0.1 : 1)
                                
                                Image(systemName: "wifi.exclamationmark")
                                    .foregroundStyle(.yellow)
                                    .opacity(errorAnimate3 ? 1 : 0.1)
                                
                            }
                            .onAppear{
                                withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                    self.errorAnimate3 = true
                                }
                            }
                            .onDisappear{
                                self.errorAnimate3 = false
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    
                }
            }

            
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
                    let color = await MainManager.shared.healthAllColor()
                    dispatch_sync_safely_main_queue {
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



extension SettingsView{
    
    func exportFiles(){
        
        DispatchQueue.global().async {
            do{
                
                let realm = try Realm()
                
                let messages = realm.objects(Message.self).sorted(byKeyPath: "createDate", ascending: false)
                let jsonData = try JSONEncoder().encode(messages)
                
                let fileManager = FileManager.default
                let tempDirectoryURL = fileManager.temporaryDirectory
                let fileName = "meow_messages_\(Date().formatString(format: "yyyy_MM_dd_HH_mm_ss")).json"
                let linkURL = tempDirectoryURL.appendingPathComponent(fileName)
                
                // 清空temp文件夹
                try fileManager
                    .contentsOfDirectory(at: tempDirectoryURL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
                    .forEach { file in
                        try? fileManager.removeItem(atPath: file.path)
                    }
                
                
                try jsonData.write(to: linkURL)
                DispatchQueue.main.async {
                    self.jsonFileUrl = linkURL
                    self.toastText = NSLocalizedString("exportSuccess", comment: "")
                    self.showLoading = false
                    self.isShareSheetPresented.toggle()
                }
                
                
             
                
                
                
                
            } catch {
    #if DEBUG
                print("errors: \(error.localizedDescription)")
    #endif
                
            }
        }
        
       
    }
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
}

#Preview {
    SettingsView()
}
