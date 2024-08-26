//
//  ChatDemo.swift
//  Meow
//
//  Created by He Cho on 2024/8/25.
//

import SwiftUI
import ExyteChat

struct ChatDemo: View {
    @Environment(\.presentationMode) private var presentationMode
    @State var messages: [ExyteChat.Message] = []
    
    // (id: UUID().uuidString, user: ExyteChat.User(id: UUID().uuidString, name: "测试", avatarURL: Bundle.main.url(forResource: "logo", withExtension: "png"), isCurrentUser: true), status: .read, createdAt: .now, text: value.text, attachments: [], recording: nil, replyMessage: nil)

    var body: some View {
        ChatView(messages: messages){value in
            
            Task{
                let data =  await ExyteChat.Message.makeMessage(id: UUID().uuidString, user: ExyteChat.User(id: UUID().uuidString, name: "测试", avatarURL: Bundle.main.url(forResource: "logo", withExtension: "png"), isCurrentUser: true), draft: value)
                DispatchQueue.main.async{
                    self.messages.append(data)
                }
            }
            debugPrint(value)
        }
        .messageUseMarkdown(messageUseMarkdown: true)
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    Image("backArrow", bundle: .current)
                }
            }
            ToolbarItem(placement: .principal) {
                HStack{
                    AsyncImageDefault(size: CGSize(width: 50, height: 50))
                    Spacer()
                }
            }
        }
    }
}


#Preview {
    NavigationStack{
        ChatDemo()
    }
    
}
