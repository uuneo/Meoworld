//
//  AppIconView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI

struct AppIconView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("setting_active_app_icon") var setting_active_app_icon:appIcon = .def
    @State var toastText = ""
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    var body: some View {
        List{
            LazyVGrid(columns: columns){
                ForEach(Array(logoImage.arr.enumerated()), id: \.offset){index,item in
                  
                    ZStack{
                        Image(item.rawValue)
                            .resizable()
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .circular))
                            .frame(width: 60,height:60)
                            .tag(appIcon.arr[index])
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(.largeTitle))
                            .scaleEffect(appIcon.arr[index] == setting_active_app_icon ? 1 : 0.1)
                            .opacity(appIcon.arr[index] == setting_active_app_icon ? 1 : 0)
                            .foregroundStyle(.green)
                        
                    }.animation(.spring, value: setting_active_app_icon)
                        .padding()
                            .listRowBackground(Color.clear)
                            .onTapGesture {
                                setting_active_app_icon = appIcon.arr[index]
                                let manager = UIApplication.shared
                                
                                var iconName:String? = manager.alternateIconName ?? appIcon.def.rawValue
                                
                                if setting_active_app_icon.rawValue == iconName{
                                    return
                                }
                                
                                if setting_active_app_icon != .def{
                                    iconName = setting_active_app_icon.rawValue
                                }else{
                                    iconName = nil
                                }
                                if UIApplication.shared.supportsAlternateIcons {
                                    Task{
                                        do {
                                            try await manager.setAlternateIconName(iconName)
                                        }catch{
#if DEBUG
                                            print(error)
#endif
                                            
                                        }
                                        DispatchQueue.main.async{
                                            dismiss()
                                        }
                                    }
                                   
                                }else{
                                
                                    self.toastText = NSLocalizedString("switchError", comment: "")
                                }
                            }
                    
                   
                }
            }
            .listRowBackground(Color.clear)
            .listRowSeparatorTint(Color.clear)
        }
        .toast(info: $toastText)
        .listStyle(GroupedListStyle())
        
        .navigationTitle(NSLocalizedString("AppIconTitle",comment: ""))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem{
                Button{
                    self.dismiss()
                }label:{
                    Image(systemName: "xmark.seal")
                }
                
            }
        }
        
    }
}

#Preview {
    AppIconView()
}
