//
//  ExampleView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI

struct ExampleView: View {
    @State private var username:String = ""
    @State private var title:String = ""
    @State private var pickerSeletion:Int = 0
    @State private var toastText = ""
    @State private var showAlart = false
    @StateObject private var manager = MainManager.shared
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
                
                customHelpItemView
               
                
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
                .toast(info: $toastText )
              
        }
    }
}

extension ExampleView{
    private var customHelpItemView:some View{
       
        ForEach(PushExample.datas,id: \.id){ item in
            let server =  manager.servers[pickerSeletion]
            let resultUrl = server.url + "/" + server.key + "/" + item.params
            Section(
                header:Text(item.header),
                footer: Text(item.footer)
            ) {
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
                                DispatchQueue.main.async {
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
            }
        }
       
    }
}

#Preview {
    ExampleView()
}
