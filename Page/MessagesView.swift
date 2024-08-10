//
//  MessagesView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import RealmSwift

struct MessagesView: View {
    @State private var mainManager = MainManager()
    @ObservedResults(Message.self,
                     sortDescriptor: SortDescriptor(keyPath: "createDate",
                                                    ascending: false)) var messagesRaw
    
    @ObservedSectionedResults(Message.self,sectionKeyPath: \.group,sortDescriptors: [ SortDescriptor(keyPath: "createDate", ascending: false)]) var messages
    
    
    @State private var showAction = false
    @State private var toastText = ""
    @State private var helpviewSize:CGSize = .zero
    @State private var showItems:Bool = false
    @State private var selectGroup:String = ""
    @State private var searchText:String = ""
    
    @State private var pageNumber:Int = 1
    @State private var toolManager = ToolsManager.shared
    
    @AppStorage("setting_active_app_icon") var setting_active_app_icon:appIcon = .def
 
    
    var body: some View {
       
            List {
                
                ForEach(messages,id: \.key){ message2 in
                    if let message = message2.first{
                        Button {
                            self.selectGroup = ToolsManager.getGroup(message.group)
                            self.showItems.toggle()
                            
                        } label: {
                            LabeledContent {
                                VStack{
                                    HStack{
                                        
                                        Text( ToolsManager.getGroup(message.group) )
                                            .font(.headline.weight(.bold))
                                            .foregroundStyle(Color("textBlack"))
                                        Spacer()
                                        Text(message.createDate.agoFormatString())
                                            .font(.caption2)
                                        Image(systemName: "chevron.forward")
                                            .font(.caption2)
                                    }
                                    
                                    HStack{
                                        Group {
                                            if let title = message.title{
                                                Text( "【\(title)】\(message.body ?? "")")
                                            }else{
                                                Text(message.body ?? "")
                                                
                                            }
                                        }
                                        .font(.footnote)
                                        .lineLimit(2)
                                        .foregroundStyle(.gray)
                                        
                                        Spacer()
                                    }
                                    
                                    
                                    
                                    
                                }
                            } label: {
                                HStack{
                                    if message2.filter({!$0.read && $0.group == message.group}).count > 0 {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 10,height: 10)
                                    }

                                    
                                    VStack( spacing:10){
                                        
                                        Group{
                                            if let icon = message.icon,
                                               ToolsManager.startsWithHttpOrHttps(icon){
                                                
                                                AsyncImageView(imageUrl: icon )
                                                
                                            }else{
                                                Image(setting_active_app_icon.toLogoImage)
                                                    .resizable()
                                            }
                                        }
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 45, height: 45, alignment: .center)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        
                                    }
                                }
                                .frame(minWidth: 60)
                            }
                          
                            
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                               
                                Task{
                                    if let group = message.group{
                                        RealmManager.shared.readMessage(group: group)
                                    }
                                }
                          
                            } label: {
                                Label(NSLocalizedString("groupMarkRead",comment: ""), systemImage: "envelope")
                            }.tint(.blue)
                        }
                    }
                    
                }.onDelete(perform: { indexSet in
                    for index in indexSet{
                        RealmManager.shared.delByGroup(ToolsManager.getGroup(messages[index].key))
                    }
                })
                
                
                
            }
            .listStyle(.plain)
            .navigationDestination(isPresented: $showItems) {
                MessageDetailView(messages: messagesRaw.where({$0.group == selectGroup}))
                    .toolbar(.hidden, for: .tabBar)
                    .navigationTitle(selectGroup)
            }
            .toolbar{

                
                ToolbarItem{
                    Button{
                        self.showAction = true
                    }label: {
                        Image("baseline_delete_outline_black_24pt")
                        
                    }  .foregroundStyle(Color("textBlack"))
                    
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)){
                
                if let filterMessages = filterMessage(messagesRaw, searchText.trimmingCharacters(in: .whitespaces)){
                    Text( String(format: NSLocalizedString("findMessageCount" ,comment: "找到\(filterMessages.count)条数据"), filterMessages.count))
                        .foregroundStyle(.gray)
                    
                    let messagesSuff = filterMessages.suffix(min(self.pageNumber * 10 , filterMessages.count))
                    
                    ForEach(messagesSuff,id: \.id){message in
                        MessageView(message: message,searchText: searchText)
                            .onAppear{
                                if message == messagesSuff.last{
                                    self.pageNumber += 1
                                }
                            }
                    }
                }else{
                    Text( String(format: NSLocalizedString("findMessageCount" ,comment: "找到 0 条数据"), 0))
                        .foregroundStyle(.gray)
                }
            }
            .actionSheet(isPresented: $showAction) {
                ActionSheet(title: Text(NSLocalizedString("deleteTimeMessage",comment: "")),buttons: [
                    .destructive(Text(NSLocalizedString("allTime",comment: "")), action: {
                        deleteMessage(.allTime)
                    }),
                    .destructive(Text(NSLocalizedString("monthAgo",comment: "")), action: {
                        deleteMessage( .lastMonth)
                    }),
                    .destructive(Text(NSLocalizedString("weekAgo",comment: "")), action: {
                        deleteMessage( .lastWeek)
                    }),
                    .destructive(Text(NSLocalizedString("dayAgo",comment: "")), action: {
                        deleteMessage( .lastDay)
                    }),
                    .destructive(Text(NSLocalizedString("hourAgo",comment: "")), action: {
                        deleteMessage( .lastHour)
                    }),
                    .default(Text(NSLocalizedString("allMarkRead",comment: "")), action: {
                        deleteMessage( .markRead)
                    }),
                    .cancel()
                    
                ])
            }
            .toast(info: $toastText)
            .onChange(of: searchText) { value in
                self.pageNumber = 1
            }
           
       
    }
}



extension MessagesView{
    
    func filterMessage(_ datas: Results<Message>, _ searchText:String)-> Results<Message>?{
        
        // 如果搜索文本为空，则返回原始数据
           guard !searchText.isEmpty else {
               return nil
           }

        return datas.filter("body CONTAINS[c] %@ OR title CONTAINS[c] %@ OR group CONTAINS[c] %@", searchText, searchText, searchText)
    }
    
    
    func deleteMessage(_ mode: mesAction){
        
        let realm = RealmManager.shared
        
        if realm.getObject()?.count == 0{
         
            self.toastText = NSLocalizedString("nothingMessage", comment: "")
           
            return
        }
        
        var date = Date()
        
        switch mode {
        case .allTime:
            let alldata = realm.getObject()
            let _ =  realm.deleteObjects(alldata)
            self.toastText =  NSLocalizedString("deleteAllMessage",comment: "")
            return
        case .markRead:
            
            let allData = realm.getObject()?.where({!$0.read})
            let _ = realm.updateObjects(allData) { data in
                data?.read = true
            }
            self.toastText =  NSLocalizedString("allMarkRead",comment: "")
            return
        case .lastHour:
            date = Date().someHourBefore(1)
        case .lastDay:
            date = Date().someDayBefore(0)
            
        case .lastWeek:
            date = Date().someDayBefore(7)
        case .lastMonth:
            date = Date().someDayBefore(30)
            
            
        }
        
        let alldata = realm.getObject()?.where({$0.createDate < date})
        
        let _ = realm.deleteObjects(alldata)
        
        self.toastText = NSLocalizedString("deleteSuccess", comment: "")
        
        
    }
  
}
#Preview {
    MessagesView()
}
