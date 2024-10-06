//
//  MessagesView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import RealmSwift

struct MessagesView: View {
	
	@ObservedSectionedResults(Message.self,sectionKeyPath: \.group,sortDescriptors: [ SortDescriptor(keyPath: "createDate", ascending: false)]) var messages
	
	@EnvironmentObject private var realm:RealmManager
	@EnvironmentObject private var manager:MainManager
    @StateObject private var toolManager = ToolsManager.shared
	@AppStorage(BaseConfig.activeAppIcon) var setting_active_app_icon:appIcon = .def
    @State private var showAction = false
    @State private var toastText = ""
    @State private var helpviewSize:CGSize = .zero
    @State private var searchText:String = ""
	@State private var showExample:Bool = false

    
    var body: some View {
        
        List {
			
            
            ForEach(messages,id: \.key){ message2 in
				
				NavigationLink {
					
					MessageDetailView(messages: message2)
						.toolbar(.hidden, for: .tabBar)
						.navigationTitle(message2.key ?? "")
				} label: {
					MessageRow(message: message2.first!, unreadCount: message2.filter { !$0.read }.count)
						.swipeActions(edge: .leading) {
							Button {
								
								Task{
									realm.readMessage(group: message2.key)
								}
								
							} label: {
								Label(NSLocalizedString("groupMarkRead",comment: ""), systemImage: realm.NReadCount(group: message2.key) == 0 ?  "envelope.open" : "envelope")
								
							}.tint(.blue)
						}
				}

				
                
            }.onDelete(perform: { indexSet in
                for index in indexSet{
                    realm.delete(group: messages[index].key)
                }
            })
            
            
			EmptyView()
        }
        .listStyle(.plain)
	
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
			SearchMessageView(searchText: $searchText)
        }
		.actionSheet(isPresented: $showAction) {
			
			ActionSheet(title: Text(NSLocalizedString("deleteTimeMessage",comment: "")),
						buttons: mesAction.allCases.map({ item in
				if item == .cancel{
					Alert.Button.cancel()
				} else if item  == .markRead{
					Alert.Button.default(Text(NSLocalizedString(item.rawValue,comment: "")), action: {
						deleteMessage( item)
					})
				}else{
					Alert.Button.destructive(Text(NSLocalizedString(item.rawValue,comment: "")), action: {
						deleteMessage(item)
					})
				}
				
			}))
		}
		.alert(info: $toastText)
		
    }
    
    
    
    func deleteMessage(_ mode: mesAction){
        
        
        if messages.count == 0{
            
            self.toastText = NSLocalizedString("nothingMessage", comment: "")
            
            return
        }
        
        var date = Date()
        
        switch mode {
        case .allTime:
            realm.delete()
            self.toastText =  NSLocalizedString("deleteAllMessage",comment: "")
            return
        case .markRead:
            realm.readMessage()
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
        
        
        realm.delete( less: date)
        
        self.toastText = NSLocalizedString("deleteSuccess", comment: "")
        
        
    }
    
	@ViewBuilder
	func MessageRow(message: Message,unreadCount: Int )-> some View{
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
						.font(.headline.weight(.bold))
						.foregroundStyle(.lightDark)
					
					Spacer()
					
					Text(message.createDate.agoFormatString())
						.font(.caption2)
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



#Preview {
    NavigationStack{
        MessagesView()
    }
    
}
