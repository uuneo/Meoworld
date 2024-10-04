//
//  MessagesView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import Shiny

struct MessagesView: View {
    
    @StateObject private var toolManager = ToolsManager.shared
    @StateObject private var manager = MainManager.shared
    
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
    
    
    @AppStorage(BaseConfig.activeAppIcon) var setting_active_app_icon:appIcon = .def
    
    @State private var showExample:Bool = false
    
    var body: some View {
        
        List {
            
            ForEach(messages,id: \.key){ message2 in
                if let message = message2.first{
                    
                    MessageRow(message: message, unreadCount: messagesRaw.filter { !$0.read && $0.group == message.group }.count)
                        .onTapGesture {
                            self.selectGroup = ToolsManager.getGroup(message.group)
                            self.showItems.toggle()
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                
                                Task{
                                    if let group = message.group{
                                        RealmManager.shared.readMessage(group: group)
                                    }
                                }
                                
                            } label: {
                                Label(NSLocalizedString("groupMarkRead",comment: ""), systemImage: RealmManager.shared.NReadCount(group: message.group) == 0 ?  "envelope.open" : "envelope")
                                
                            }.tint(.blue)
                        }
                }
                
            }.onDelete(perform: { indexSet in
                for index in indexSet{
                    RealmManager.shared.delete(group: messages[index].key)
                }
            })
            
            
            
        }
        .listStyle(.plain)
        .navigationDestination(isPresented: $showItems) {
            MessageDetailView(messages: messagesRaw.where({$0.group == selectGroup}))
                .toolbar(.hidden, for: .tabBar)
                .navigationTitle(selectGroup)
        }
        
        .navigationDestination(isPresented: $showExample){
            ExampleView()
        }
        .tipsToolbar(wifi: Monitors.shared.isConnected, notification: Monitors.shared.isAuthorized, callback: {
            manager.openSetting()
        })
        .toolbar{
            
            
            ToolbarItem {
                
                Button{
                    self.showExample.toggle()
                }label:{
                    Image(systemName: "questionmark.circle")
                    
                } .foregroundStyle(.lightDark)
                    .accessibilityIdentifier("HelpButton")
            }
            
            
            ToolbarItem{
				
				if ISPAD{
					Menu {
						ForEach(mesAction.allCases, id: \.self){ item in
							Button{
								deleteMessage(item)
							}label:{
								Label(NSLocalizedString(item.rawValue,comment: ""), systemImage: (item == .cancel ? "arrow.uturn.right.circle" : item == .markRead ? "text.badge.checkmark" : "xmark.bin.circle"))
							}
						}
					} label: {
						Image("baseline_delete_outline_black_24pt")
							.foregroundStyle(.lightDark)
					}
						
						
				}else{
					
					Button{
						self.showAction = true
					}label: {
						Image("baseline_delete_outline_black_24pt")
						
					}  .foregroundStyle(.lightDark)
					
					
				}
					
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic)){
            searchableContent
        }
        .actionSheet(isPresented: $showAction) {
            DelAction
        }
        .toast(info: $toastText)
		.onChange(of: searchText) { value in
			self.pageNumber = 1
		}
        
        
    }
    
    private var DelAction:ActionSheet{
		
		let menuButtons = mesAction.allCases.map({ item in
			
			if item == .cancel{
				return Alert.Button.cancel()
			} else if item  == .markRead{
				return Alert.Button.default(Text(NSLocalizedString(item.rawValue,comment: "")), action: {
					deleteMessage( item)
				})
			}else{
				return Alert.Button.destructive(Text(NSLocalizedString(item.rawValue,comment: "")), action: {
					deleteMessage(item)
				})
			}
			
		})
		
		return ActionSheet(title: Text(NSLocalizedString("deleteTimeMessage",comment: "")),buttons: menuButtons)
    }
    
    
    // 搜索结果视图
      private var searchableContent: some View {
          Group{
              if let filterMessages = filterMessage(messagesRaw, searchText.trimmingCharacters(in: .whitespaces)) {
                  Text(String(format: NSLocalizedString("findMessageCount", comment: "找到\(filterMessages.count)条数据"), filterMessages.count))
                      .foregroundStyle(.gray)
                  
                  let messagesToShow = filterMessages.suffix(min(self.pageNumber * 10, filterMessages.count))
                  
                  ForEach(messagesToShow, id: \.id) { message in
                      MessageView(message: message, searchText: searchText)
                          .onAppear {
                              if message == messagesToShow.last {
                                  self.pageNumber += 1
                              }
                          }
                  }
              } else {
                  Text(String(format: NSLocalizedString("findMessageCount", comment: "找到 0 条数据"), 0))
                      .foregroundStyle(.gray)
              }
          }
      }
    
    
    func filterMessage(_ datas: Results<Message>, _ searchText:String)-> Results<Message>?{
        
        // 如果搜索文本为空，则返回原始数据
        guard !searchText.isEmpty else {
            return nil
        }
        
        return datas.filter("body CONTAINS[c] %@ OR title CONTAINS[c] %@ OR group CONTAINS[c] %@", searchText, searchText, searchText)
    }
    
    
    func deleteMessage(_ mode: mesAction){
        
        
        if messagesRaw.count == 0{
            
            self.toastText = NSLocalizedString("nothingMessage", comment: "")
            
            return
        }
        
        var date = Date()
        
        switch mode {
        case .allTime:
            RealmManager.shared.delete()
            self.toastText =  NSLocalizedString("deleteAllMessage",comment: "")
            return
        case .markRead:
            RealmManager.shared.readMessage()
            self.toastText =  NSLocalizedString("allMarkRead",comment: "")
            return
		case .cancel:
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
        
        
        RealmManager.shared.delete( less: date)
        
        self.toastText = NSLocalizedString("deleteSuccess", comment: "")
        
        
    }
    
    
    
    
}





// 单独抽取的消息行视图
struct MessageRow: View {
    let message: Message
    let unreadCount: Int
    
    var body: some View {
        
        Button {
            // 点击事件在外部处理
        } label: {
            HStack {
                if unreadCount > 0 {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                }
                
                AvatarView(id: message.id, icon: message.icon, mode: message.mode)
                    .frame(width: 45, height: 45)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                VStack(alignment: .leading) {
                    HStack {
                        Text(message.group  ?? NSLocalizedString("defaultGroup",comment: ""))
                            .shiny()
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.lightDark)
                        
                        Spacer()
                        
                        Text(message.createDate.agoFormatString())
                            .font(.caption2)
                            .shiny()
                    }
                    
                    HStack {
                        if let title = message.title {
                            Text("【\(title)】\(message.body ?? "")")
                        } else {
                            Text(message.body ?? "")
                        }
                    }
                    .font(.footnote)
                    .lineLimit(2)
                    .foregroundStyle(.gray)
                }
            }
        }
    }
    
    
}










#Preview {
    NavigationStack{
        MessagesView()
    }
    
}
