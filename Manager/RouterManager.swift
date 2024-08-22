//
//  RouterManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation
import SwiftUI

class RouterManager:ObservableObject{
    static let shared = RouterManager()
    
    @Published var page:TabPage = .message
    
    @Published var sheetPage:SubPage = .none
    @Published var fullPage:SubPage = .none
    @Published var webUrl:String = ""
    @Published var scanUrl:String = ""
    
    @Published var showServerListView:Bool = false
    
    
    var fullPageShow:Binding<Bool>{
    
        Binding {
            self.fullPage != .none
        } set: { value in
            if !value {
                self.fullPage = .none
            }
        }
    }
    
    var sheetPageShow:Binding<Bool>{
        Binding {
            self.sheetPage != .none
        } set: { value in
            if !value {
                self.sheetPage = .none
            }
        }
        
    }
    
}
