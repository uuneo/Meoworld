//
//  FontAnimation+.swift
//  Meow
//
//  Created by He Cho on 2024/8/24.
//

import Foundation
import SwiftUI


struct FontAnimation: Animatable, ViewModifier{
    
    var size:Double
    var weight:Font.Weight
    var design:Font.Design
    var animatableData: Double{
        get { size }
        set { size = newValue }
    }
    
    func body(content: Content) -> some View {
        content.font(.system(size: size,weight: weight,design: design))
    }
    
}

extension View {
    func animationFont(size:Double,weight: Font.Weight = .regular,design:Font.Design = .default )-> some View{
        self.modifier(FontAnimation(size: size, weight: weight, design: design))
    }
}
