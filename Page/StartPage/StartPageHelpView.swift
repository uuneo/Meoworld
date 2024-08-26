//
//  StartPageHelpView.swift
//  Meow
//
//  Created by He Cho on 2024/8/25.
//

import SwiftUI
import ConcentricOnboarding






struct StartPageHelpView: View {
    
    @Binding var show:Bool
    
    @State private var currentIndex: Int = 0
    
    var lastIndex:Bool{
        currentIndex + 1 == MockData.pages.count
    }
    
    var body: some View {
        
        ConcentricOnboardingView(pageContents: MockData.pages.map { (HelpPageView(page: $0), $0.color) })
            .duration(1)
            .didChangeCurrentPage { value in
                self.currentIndex = value
            }.nextIcon(lastIndex ? "house" : "forward", size: CGSize(width: 30, height: 30))
            .insteadOfCyclingToFirstPage {
                self.show.toggle()
            }
    }
}

#Preview {
    StartPageHelpView(show: .constant(true))
}
