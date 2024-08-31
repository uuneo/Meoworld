//
//  toolbar+.swift
//  Meow
//
//  Created by He Cho on 2024/8/31.
//

import Foundation
import SwiftUI



struct TipsToolBarItemsModifier: ViewModifier{
    
    @State private var errorAnimate1: Bool = false
    @State private var errorAnimate2: Bool = false
    @State private var errorAnimate3: Bool = false
    
    var isConnected:Bool
    var isAuthorized:Bool
    
    let onAppearAction:() -> Void
    
    func body(content: Content) -> some View {
        content.toolbar {
            Group{
                
                if !isConnected && isAuthorized{
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            onAppearAction()
                        } label: {
                            Image(systemName: "wifi.exclamationmark")
                                .foregroundStyle(.yellow)
                                .opacity(errorAnimate1 ? 1 : 0.1)
                                .onAppear{
                                    withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                        self.errorAnimate1 = true
                                    }
                                }
                                .onDisappear{
                                    self.errorAnimate1 = false
                                }
                            
                        }
                        
                    }
                }
                
                if !isAuthorized && isConnected {
                    
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            onAppearAction()
                        } label: {
                            Image(systemName: "bell.slash")
                                .foregroundStyle(.red)
                                .opacity(errorAnimate2 ? 0.1 : 1)
                                .onAppear{
                                    withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                        self.errorAnimate2 = true
                                    }
                                }
                                .onDisappear{
                                    self.errorAnimate2 = false
                                }
                            
                        }
                        
                    }
                    
                    
                }
                
                if !isAuthorized && !isConnected  {
                    
                    ToolbarItem (placement: .topBarLeading){
                        Button {
                            onAppearAction()
                        } label: {
                            
                            ZStack{
                                
                                Image(systemName: "bell.slash")
                                    .foregroundStyle(.red)
                                    .opacity(errorAnimate3 ? 0.1 : 1)
                                
                                Image(systemName: "wifi.exclamationmark")
                                    .foregroundStyle(.yellow)
                                    .opacity(errorAnimate3 ? 1 : 0.1)
                                
                            }
                            .onAppear{
                                withAnimation(Animation.bouncy(duration: 0.5).repeatForever()) {
                                    self.errorAnimate3 = true
                                }
                            }
                            .onDisappear{
                                self.errorAnimate3 = false
                            }
                            
                            
                            
                        }
                        
                    }
                    
                    
                }
            }
        }
    }
}


extension View{
    func tipsToolbar(wifi:Bool, notification:Bool , callback: @escaping () -> Void) -> some View{
        self.modifier(TipsToolBarItemsModifier(isConnected: wifi, isAuthorized: notification, onAppearAction: callback))
    }
}
