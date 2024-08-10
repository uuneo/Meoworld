//
//  LoadingView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//
import SwiftUI


struct LoadingPress: ViewModifier{
    
    var show:Bool = false
    var title:String = ""
    
    func body(content: Content) -> some View {
        
        ZStack {
            content
                .disabled(show)
               
            
            if show{
                VStack{
                    
                    ProgressView()
                        .scaleEffect(3)
                        .padding()
                    
                    Text(title)
                        .font(.caption)
                }
                .toolbar(.hidden, for: .tabBar)
            }
               
                
        }
    }
}


extension View {
    func loading(_ show:Bool, _ title:String = "")-> some View{
        modifier(LoadingPress(show: show, title: title))
    }
}
