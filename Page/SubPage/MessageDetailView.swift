//
//  MessageDetailView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI

struct MessageDetailView: View {
    var messages:Results<Message>
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    @State private var toastText:String = ""
    @State private var pageNumber:Int = 1
    var showMsgCount:Int{
        min(pageNumber * 10, messages.count)
    }
    var body: some View {
        
        List {
            ForEach(messages.prefix( showMsgCount ), id: \.id) { message in
                    MessageView(message: message)
                    .listRowBackground(Color.clear)
                    .listSectionSeparator(.hidden)
                        .swipeActions(edge: .leading) {
                            Button {
                               
                                RealmManager.shared.readMessage(id: message.id)
                                self.toastText = NSLocalizedString("messageModeChanged", comment: "")
                                
                            } label: {
                                Label(message.read ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: message.read ? "envelope.open": "envelope")
                            }.tint(.blue)
                        }
                        .onAppear{
                            if message == messages.prefix( showMsgCount ).last {
                                self.pageNumber += 1
                            }
                        }
                    
            }.onDelete { IndexSet in
                for k in IndexSet{
                    RealmManager.shared.delete(id: messages[k].id)
                }
            }
                
            }
        .toolbar{
            ToolbarItem {
                HStack{
                    Text("\(showMsgCount)")
                    Text("/")
                    Text("\(messages.count)")
                }.font(.caption)
            }
        }
           
            .toast(info: $toastText)
            .onChange(of: messages) { value in
                if value.count <= 0 {
                    dismiss()
                }
            }.onAppear{
                
                let notReadMessages = messages.where({!$0.read})
                
                if notReadMessages.count > 0{
                    DispatchQueue.global().async {
                        // 获取后台线程上的 Realm 实例
                        let backgroundRealm = try! Realm()
                        do{
                            try backgroundRealm.write {
                                for k in notReadMessages{
                                    if let item =  backgroundRealm.thaw(k){
                                        item.read = true
                                    }
                                   
                                }
                            }
                        }catch{
                            debugPrint(error)
                        }
                       
                    }
                }
                
              
               
            }
        
    }
}

//#Preview {
//    MessageDetailView(messages: )
//}
