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
    static let datas:[PushExample] = [
        
        PushExample(header: NSLocalizedString("pushExampleHeader1",comment: ""), footer: NSLocalizedString("pushExampleFooter1",comment: ""), title: NSLocalizedString("pushExampleTitle1",comment: ""),params: NSLocalizedString("pushExampleParams1",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader2",comment: ""), footer: NSLocalizedString("pushExampleFooter2",comment: ""), title: NSLocalizedString("pushExampleTitle2",comment: ""),params: NSLocalizedString("pushExampleParams2",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader3",comment: ""), footer: NSLocalizedString("pushExampleFooter3",comment: ""), title: NSLocalizedString("pushExampleTitle3",comment: ""),params: NSLocalizedString("pushExampleParams3",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader4",comment: ""), footer: NSLocalizedString("pushExampleFooter4",comment: ""), title: NSLocalizedString("pushExampleTitle4",comment: ""),params: NSLocalizedString("pushExampleParams4",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader5",comment: ""), footer: NSLocalizedString("pushExampleFooter5",comment: ""), title: NSLocalizedString("pushExampleTitle5",comment: ""),params: NSLocalizedString("pushExampleParams5",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader6",comment: ""), footer: NSLocalizedString("pushExampleFooter6",comment: ""), title: NSLocalizedString("pushExampleTitle6",comment: ""),params: NSLocalizedString("pushExampleParams6",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader7",comment: ""), footer: NSLocalizedString("pushExampleFooter7",comment: ""), title: NSLocalizedString("pushExampleTitle7",comment: ""),params: NSLocalizedString("pushExampleParams7",comment: "") ),
        
        PushExample(header: NSLocalizedString("pushExampleHeader8",comment: ""), footer: NSLocalizedString("pushExampleFooter8",comment: ""), title: NSLocalizedString("pushExampleTitle8",comment: ""),params: NSLocalizedString("pushExampleParams8",comment: "")),
       
        PushExample(header: NSLocalizedString("pushExampleHeader9",comment: ""), footer: NSLocalizedString("pushExampleFooter9",comment: ""), title: NSLocalizedString("pushExampleTitle9",comment: ""),params: NSLocalizedString("pushExampleParams9",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader10",comment: ""), footer: NSLocalizedString("pushExampleFooter10",comment: ""), title: NSLocalizedString("pushExampleTitle10",comment: ""),params: NSLocalizedString("pushExampleParams10",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader11",comment: ""), footer: NSLocalizedString("pushExampleFooter11",comment: ""), title: NSLocalizedString("pushExampleTitle11",comment: ""),params: NSLocalizedString("pushExampleParams11",comment: "")),
        
        PushExample(header: NSLocalizedString("pushExampleHeader12",comment: ""), footer: NSLocalizedString("pushExampleFooter12",comment: ""), title: NSLocalizedString("pushExampleTitle12",comment: ""),params: NSLocalizedString("pushExampleParams12",comment: "")),
        
       
        
        
    ]
}
