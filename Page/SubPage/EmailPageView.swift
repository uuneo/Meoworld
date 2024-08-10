//
//  EmailPageView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI


struct EmailPageView:View {
    @State var showLoading:Bool = false
    @State var toastText:String = ""
    @StateObject private var toolsManager = ToolsManager.shared
    var body: some View {
        List{
            
            HStack{
                
                Text( NSLocalizedString("mailTestTips", comment: "主题包含: NewBear"))
                    .font(.caption2)
                Spacer()
                Button{
                    self.removeFailToEmail()
                    self.showLoading = true
                    DispatchQueue.main.async {
                        ToolsManager.sendMail(config: toolsManager.email, title:   NSLocalizedString("toMailTestTitle", comment: "自动化: NewBear"), text:NSLocalizedString("toMailTestText", comment:  "{title:\"标题\",...}")){ error in
                            
                           
                            
                            
                            if error != nil {
                                
                                self.toastText = NSLocalizedString("sendMailFail", comment:  "调用失败")
                            }else{
                                
                                self.toastText = NSLocalizedString("sendMailSuccess", comment:   "调用成功")
                            }
                            
                            
                            
                            
                            
                            dispatch_sync_safely_main_queue {
                               
                                self.showLoading = false
                            }
                            
                        }
                    }

                   
                }label: {
                    if showLoading{
                        ProgressView()
                    }else{
                        Text(NSLocalizedString("sendMailTestBtn", comment:  "测试"))
                    }
                }
                .buttonStyle(BorderedButtonStyle())
                
                   
            }.listRowBackground(Color.clear)
            .listRowSeparator(.hidden)

            Section(header:Text(NSLocalizedString("emailConfigHeader", comment: "邮件服务器配置,本地化服务"))) {
                HStack{
                    Text("Smtp:")
                        .foregroundStyle(.gray)
                    TextField("smtp.qq.com", text: $toolsManager.email.smtp)
                        .textFieldStyle(.roundedBorder)
                       
                }
                HStack{
                    Text("Email:")
                        .foregroundStyle(.gray)
                    TextField("@twown.com", text: $toolsManager.email.email)
                        .textFieldStyle(.roundedBorder)
                      
                }
                HStack{
                    Text("Password:")
                        .foregroundStyle(.gray)
                    SecureField(NSLocalizedString("emailPasswordPl", comment: "请输入密码"), text: $toolsManager.email.password)
                        .textFieldStyle(.roundedBorder)
                }
            }
            
            Section(header:Text(NSLocalizedString("tomailListHeader", comment: "接收邮件列表"))) {
                HStack{
                    Spacer()
                    Button{
                        toolsManager.email.toEmail.insert(toEmailConfig(""), at: 0)
                    }label: {
                        Image(systemName: "plus.square.dashed")
                            .font(.headline)
                    }.buttonStyle(.borderless)
                }
                
                ForEach($toolsManager.email.toEmail, id: \.id){item in
                    HStack{
                        Text("ToMail:")
                            .foregroundStyle(.gray)
                        TextField("@twown.com", text: item.mail)
                            .textFieldStyle(.roundedBorder)
                    }
                        
                }.onDelete(perform: { indexSet in
                    toolsManager.email.toEmail.remove(atOffsets: indexSet)
                })
            }
            
           
            
            
        }.navigationTitle(NSLocalizedString("emailNavigationTitle", comment: "邮件自动化"))
            .toolbar {
                ToolbarItem {
                    Button{
                        RouterManager.shared.webUrl = otherUrl.emailHelpUrl
                        RouterManager.shared.fullPage = .web
                    }label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .toast(info: $toastText)
            .onDisappear{
                self.removeFailToEmail()
            }
            
    }
}


extension EmailPageView{
    func removeFailToEmail(){
        toolsManager.email.toEmail.removeAll(where: {!ToolsManager.isValidEmail($0.mail)})
    }
}
