//
//  button+.swift
//  Meow
//
//  Created by He Cho on 2024/8/27.
//

import Foundation
import SwiftUI

struct CircleButtonStyle: ButtonStyle {

    var imageName: String
    var foreground = Color.black
    var background = Color.white
    var width: CGFloat = 40
    var height: CGFloat = 40

    func makeBody(configuration: Configuration) -> some View {
        let isPress = configuration.isPressed
        Circle()
            .fill(background)
            .overlay(
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isPress ? foreground.opacity(0.5) : foreground)
                    .padding(12)
            )
            .frame(width: width, height: height)
            .scaleEffect(isPress ? 0.9 : 1)
            .animation(.bouncy, value: isPress)
            
    }
}


extension View {

    func fontBold(color: Color = .black, size: CGFloat) -> some View {
        foregroundColor(color).font(.custom("Circe-Bold", size: size))
    }

    func fontRegular(color: Color = .black, size: CGFloat) -> some View {
        foregroundColor(color).font(.custom("Circe", size: size))
    }
}
