//
//  OneHelpPage.swift
//  Meow
//
//  Created by He Cho on 2024/8/25.
//

import SwiftUI

struct HelpPageView: View {
    let page: PageData
   
    
    var imageWidth: CGFloat {
        min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)  - 100
    }
    
    
    
       let textWidth: CGFloat = 350
       
       var body: some View {
           let size = UIImage(named: page.imageName)?.size ?? .zero
           let aspect = size.width / size.height
           
           return VStack(alignment: .center, spacing: 50) {
               Text(page.title)
                   .font(.system(size: 40, weight: .bold, design: .rounded))
                   .foregroundColor(page.textColor)
                   .frame(width: textWidth)
                   .multilineTextAlignment(.center)
               Image(page.imageName)
                   .resizable()
                   .aspectRatio(aspect, contentMode: .fit)
                   .frame(width: imageWidth,height: imageWidth - 120)
                   .cornerRadius(40)
                   .clipped()
               VStack(alignment: .center, spacing: 5) {
                   Text(page.header)
                       .font(.system(size: 25, weight: .bold, design: .rounded))
                       .foregroundColor(page.textColor)
                       .frame(width: 300, alignment: .center)
                       .multilineTextAlignment(.center)
                   Text(page.content)
                       .font(Font.system(size: 18, weight: .bold, design: .rounded))
                       .foregroundColor(page.textColor)
                       .frame(width: 300, alignment: .center)
                       .multilineTextAlignment(.center)
               }
           }
       }
}

#Preview {
    HelpPageView(page:  MockData.pages[0])
        .background(Color.black)
}
