//
//  ServersView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI

struct ServersView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showAction:Bool = false
    @State private var isEditing:EditMode = .inactive
    @State private var toastText:String = ""
    @State private var serverText:String = ""
    @State private var serverName:String = ""
    @State private var pickerSelect:requestHeader = .https
    
    @State private var login:Bool = false
    var showClose:Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                
                List{
                    
                    
                    
                    if isEditing == .active{
                        Section {
                            TextField(NSLocalizedString("inputServerAddress",comment: ""), text: $serverName)
                                .textContentType(.flightNumber)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding(.leading, 100)
                                .overlay{
                                    HStack{
                                        Picker(selection: $pickerSelect) {
                                            Text(requestHeader.http.rawValue).tag(requestHeader.http)
                                            Text(requestHeader.https.rawValue).tag(requestHeader.https)
                                        }label: {
                                            Text("")
                                        } .pickerStyle(.automatic)
                                            .frame(maxWidth: 100)
                                            .offset(x:-30)
                                        Spacer()
                                    }
                                }
                            
                        }header: {
                            Text(NSLocalizedString("addNewServerListAddress",comment: ""))
                        }footer: {
                            HStack{
                                Button{
                                    RouterManager.shared.webUrl = otherUrl.delpoydoc
                                    RouterManager.shared.fullPage = .web
                                }label: {
                                    Text(NSLocalizedString("checkServerDeploy",comment: ""))
                                        .font(.caption2)
                                }
                                
                                Spacer()
                                
                                Button{
                                    
                                    
                                    let (success,_) = MainManager.shared.addServer(url: serverInfo.serverDefault.url)
                                    if success{
                                        self.dismiss()
                                    }
                                }label: {
                                    Text(NSLocalizedString("recoverDefaultServer",comment: ""))
                                        .font(.caption2)
                                }
                            }.padding(.vertical)
                        }
                        
                        
                    }
                    
                    Text("")
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    
                    
                    
                    ForEach(MainManager.shared.servers,id: \.id){item in
                        HStack(alignment: .center){
                            Image(item.status ? "online": "offline")
                                .padding(.horizontal,5)
                            VStack{
                                HStack(alignment: .bottom){
                                    Text(NSLocalizedString("serverName",comment: "") + ":")
                                        .font(.system(size: 10))
                                        .frame(width: 40)
                                    Text(item.name)
                                        .font(.headline)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    Spacer()
                                }
                                
                                HStack(alignment: .bottom){
                                    Text("KEY:")
                                        .frame(width:40)
                                    Text(item.key)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    Spacer()
                                } .font(.system(size: 10))
                                
                            }
                            Spacer()
                            Image(systemName: "doc.on.doc")
                                .onTapGesture{
                                    self.toastText = NSLocalizedString("copySuccessText", comment: "")
                                    MainManager.shared.copy(text: item.url + "/" + item.key)
                                }
                            
                        }
                        .padding(.vertical,5)
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            
                            Button {
                                self.login.toggle()
                                
                            } label: {
                                Text(NSLocalizedString("replaceKeyWithMail", comment: "修改key"))
                            }.tint(.blue)
                        }
                        .listRowSeparator(.hidden)
                        .swipeActions(edge: .leading) {
                            Button{
                                
                                if let index = MainManager.shared.servers.firstIndex(where: {$0.id == item.id}){
                                    MainManager.shared.servers[index].key = ""
                                }
                                
                                Task{
                                    await MainManager.shared.register(server: item)
                                }
                                self.toastText = NSLocalizedString("controlSuccess", comment: "")
                                
                            }label: {
                                Text(NSLocalizedString("resetKey",comment: "重置Key"))
                            }.tint(.red)
                        }
                        
                    }
                    .onDelete(perform: { indexSet in
                        if isEditing == .active{
                            if  MainManager.shared.servers.count > 1{
                                MainManager.shared.servers.remove(atOffsets: indexSet)
                            }else{
                                self.toastText =  NSLocalizedString("needOneServer", comment: "")
                            }
                        }else{
                            self.toastText = NSLocalizedString("editingtips", comment: "编辑状态")
                        }
                    })
                    .onMove(perform: { indices, newOffset in
                        MainManager.shared.servers.move(fromOffsets: indices, toOffset: newOffset)
                    })
                    
                    
                }
                .listRowSpacing(20)
                .refreshable {
                    await MainManager.shared.registerAll()
                }
                
                
            }
            
            .toast(info: $toastText)
            
            .toolbar{
                
                ToolbarItem {
                    Button {
                        RouterManager.shared.fullPage = .scan
                    } label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    
                }
                
                ToolbarItem {
                    EditButton()
                }
                
                
                if showClose {
                    
                    ToolbarItem{
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.seal")
                        }
                        
                    }
                }
            }
            .environment(\.editMode, $isEditing)
            .navigationTitle(NSLocalizedString("serverList",comment: ""))
            
            .onChange(of: isEditing) { value in
                
                if value == .inactive && serverName.count > 0{
                    let (_, toast) =  MainManager.shared.addServer(pickerSelect.rawValue, url: serverName)
                    self.toastText = toast
                    self.serverName = ""
                }
                
            }
            
            .fullScreenCover(isPresented: $login) {
                ChangeKeyWithEmailView()
            }
            
        }
    }
}

#Preview {
    ServersView()
}
