//
//  MessageView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI
import RealmSwift

struct MessageView: View {
	@EnvironmentObject private var manager:MainManager
    @ObservedRealmObject var message:Message
    @State private var toastText:String = ""
    var searchText:String = ""
    var body: some View {
        Section {
            
            HStack(alignment: .bottom){
                AvatarView(id: message.id, icon: message.icon, mode: message.mode)
                    .frame(width: 35, height: 35, alignment: .center)
                    .clipped() 
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(alignment: .topTrailing) {
                        if let _ =  message.url {
                            Image(systemName: "link")
                                .foregroundStyle(.green)
                                .offset(x:5 , y: -5)
                        }
                    }
                    .onTapGesture {
                        if let url =  message.url{
                            
							manager.openUrl(url: url)
                        }
                        
                    }
                    .padding(.trailing)
                
                VStack(alignment: .leading, spacing:5){
                    
                    HStack{
                        if let title = message.title{
                            highlightedText(searchText: searchText, text: title)
                                .font(.system(.headline))
                                .textSelection(.enabled)
                            Spacer()
                        }
                    }
                    
                    HStack{
                        if let body = message.body{
                            highlightedText(searchText: searchText, text: body)
                                .font(.subheadline)
                                .textSelection(.enabled)
                        }
                        
                        Spacer()
                    }
                    
                }
                .padding(10)
                .background(Color("lightAndgray"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .alert(info: $toastText)
            
        }header: {
            HStack{
                Spacer()
                Text(message.createDate.agoFormatString())
                    .font(.caption2)
                
                
            }
            
        }
        
        
        
    }
	
	func highlightedText(searchText: String, text: String) -> some View {
		// 将搜索文本和目标文本都转换为小写
		let lowercasedSearchText = searchText.lowercased()
		let lowercasedText = text.lowercased()
		
		// 在小写版本中查找范围
		guard let range = lowercasedText.range(of: lowercasedSearchText) else {
			return Text(text)
		}
		
		// 计算原始文本中的索引
		let startIndex = text.distance(from: text.startIndex, to: range.lowerBound)
		let endIndex = text.distance(from: text.startIndex, to: range.upperBound)
		
		// 使用原始文本创建前缀、匹配文本和后缀
		let prefix = Text(text.prefix(startIndex))
		let highlighted = Text(text[text.index(text.startIndex, offsetBy: startIndex)..<text.index(text.startIndex, offsetBy: endIndex)]).bold().foregroundColor(.red)
		let suffix = Text(text.suffix(text.count - endIndex))
		
		// 返回组合的文本视图
		return prefix + highlighted + suffix
	}
	
	func limitTextToLines(_ text: String, charactersPerLine: Int) -> String {
		var result = ""
		var currentLineCount = 0
		
		for char in text {
			result.append(char)
			if char.isNewline || currentLineCount == charactersPerLine {
				result.append("\n")
				currentLineCount = 0
			} else {
				currentLineCount += 1
			}
		}
		
		return result
	}
    
}


#Preview {
    
    List {
        MessageView(message: Message(value: [ "id":"123","title":"123","read":true,"icon":"error","group":"123","image":"https://day.app/assets/images/avatar.jpg","body":"123"]))
            .frame(width: 300)
            .listRowBackground(Color.clear)
            .listSectionSeparator(.hidden)
        
    }.listStyle(GroupedListStyle())
    
    
}
