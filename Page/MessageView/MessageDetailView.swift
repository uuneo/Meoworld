//
//  MessageDetailView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI
import RealmSwift

struct MessageDetailView: View {
	var messages:ResultsSection<Optional<String>, Message>
	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject private var realm:RealmManager
	@State private var toastText:String = ""

	var body: some View {
		
		List {
			LazyVStack{
				ForEach(messages, id: \.id) { message in
					MessageView(message: message)
						.listRowBackground(Color.clear)
						.listSectionSeparator(.hidden)
						.swipeActions(edge: .leading) {
							Button {
								realm.readMessage(id: message.id)
								self.toastText = NSLocalizedString("messageModeChanged", comment: "")
								
							} label: {
								Label(message.read ? NSLocalizedString("markNotRead",comment: "") :  NSLocalizedString("markRead",comment: ""), systemImage: message.read ? "envelope.open": "envelope")
							}.tint(.blue)
						}
					
				}.onDelete { IndexSet in
					for k in IndexSet{
						realm.delete(id: messages[k].id)
					}
				}
			}
			
			
		}
		.toolbar{
			ToolbarItem {
				Text("\(messages.count)")
				.font(.caption)
			}
		}
		
		.alert(info: $toastText)
		.onChange(of: messages) { _,value in
			if value.count <= 0 {
				dismiss()
			}
		}.onAppear{
			
			let notReadMessages = messages.filter({!$0.read})
			
			if notReadMessages.count > 0{
				// 获取后台线程上的 Realm 实例
				Task{
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
