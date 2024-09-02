//
//  PushExample.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation

struct PushExample:Identifiable {
    var id = UUID().uuidString
    var header,footer,title,params:String
    
    static let datas:[PushExample] =  Array(0...12).map({ PushExample(header: NSLocalizedString("pushExampleHeader\($0)",comment: ""), footer: NSLocalizedString("pushExampleFooter\($0)",comment: ""), title: NSLocalizedString("pushExampleTitle\($0)",comment: ""),params: NSLocalizedString("pushExampleParams\($0)",comment: ""))})
}
