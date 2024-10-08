//
//  ExampleView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI

struct ExampleView: View {
	@EnvironmentObject private var manager:MainManager
    @State private var username:String = ""
    @State private var title:String = ""
    @State private var pickerSeletion:Int = 0
    @State private var toastText = ""
    @State private var showAlart = false
	
    var body: some View {
        NavigationStack{

            List{
                
                HStack{
                    Spacer()
                    Picker(selection: $pickerSeletion, label: Text(NSLocalizedString("changeServer",comment: ""))) {
                        ForEach(manager.servers.indices, id: \.self){index in
                            let server = manager.servers[index]
                            Text(server.name).tag(server.id)
                        }
                    }.pickerStyle(MenuPickerStyle())
                       
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                
                customHelpItemView()
               
                
            }.listStyle(GroupedListStyle())
            
                .toolbar{
                    ToolbarItem {
                        
                        NavigationLink {
                            RingtongView()
                                .toolbar(.hidden, for: .tabBar)
                        } label: {
                            Image(systemName: "headphones.circle")
                                .foregroundStyle(Color.gray)
                        }
                    }
                
                    
                }
                .alert(info: $toastText )
                .navigationTitle(NSLocalizedString("useExample",comment: ""))
              
        }
    }
	
	
	@ViewBuilder
	func customHelpItemView() -> some View{
	   
		ForEach(PushExample.datas,id: \.id){ item in
			let server =  manager.servers[pickerSeletion]
			let resultUrl = server.url + "/" + server.key + "/" + item.params
			Section{
				HStack{
					Text(item.title)
						.font(.headline)
						.fontWeight(.bold)
					Spacer()
					Image(systemName: "doc.on.doc")
						.padding(.horizontal)
						.onTapGesture {
							UIPasteboard.general.string = resultUrl
							self.toastText = NSLocalizedString("copySuccessText", comment:  "复制成功")
						}
					Image(systemName: "safari")
						.onTapGesture {
							Task{
								let ok =  await manager.health(url: manager.servers[pickerSeletion].url + "/health" )
								await MainActor.run {
									if ok{
										if let url = URL(string: resultUrl){
											UIApplication.shared.open(url)
										}
									}else{
										self.toastText = NSLocalizedString("offline", comment:  "复制成功")
										
									}
								}
							}
							
						}
				}
				Text(resultUrl).font(.caption)
			   
			}header:{
				Text(item.header)
			}footer:{
				VStack(alignment: .leading){
					Text(item.footer)
					Divider()
						.background(Color.blue)
				}

			}
			
		   
		}
	   
	}
}


#Preview {
    ExampleView()
}
