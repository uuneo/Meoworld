//
//  RingtongView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import AVFoundation
import UIKit

struct RingtongView: View {
    @Environment(\.dismiss) var dismiss
    @State var toastText = ""
    @State private var showUpload:Bool = false
    
    var audioMusics:([URL],[URL]){
        AudioPlayerManager.shard.listFilesInDirectory()
    }
    var body: some View {
        List {
            Section{
                ForEach(audioMusics.1, id: \.self) { url in
                    RingtoneItemView(audio: url,audioPlayerManager: AudioPlayerManager.shard,toastText: $toastText)
                        
                }.onDelete { indexSet in
                    for index in indexSet{
                        AudioPlayerManager.shard.deleteSound(url: audioMusics.1[index])
                    }
                }
            }header: {
                Text(NSLocalizedString("customRing", comment: "自定义铃声"))
            }
            
           
            
            Section {
                HStack{
                    Spacer()
                    Button {
                        self.showUpload.toggle()
#if DEBUG
                        print("上传铃声")
#endif
           
                       
                    } label: {
                        Label(NSLocalizedString("uploadRing", comment: "上传铃声"), systemImage: "music.note" )
                    }
                    .fileImporter(isPresented: $showUpload, allowedContentTypes:  UTType.types(tag: "caf",
                                                                                               tagClass: UTTagClass.filenameExtension,
                                                                                               conformingTo: nil)) { result in
                        switch result{
                        case .success(let file):
                            defer {
                                   file.stopAccessingSecurityScopedResource()
                               }
#if DEBUG
                            print(file)
#endif
                           
                            if file.startAccessingSecurityScopedResource() {
                                AudioPlayerManager.shard.saveSound(url: file)
                            }else{
#if DEBUG
                                print("保存失败")
#endif
                  
                               
                            }
                            
                        case .failure(let err):
#if DEBUG
                            print(err)
#endif
                           
                        }
                    }
                    
                    Spacer()
                }
            }footer: {
                HStack{
                    Text(NSLocalizedString("ringTextHead", comment: "请先将铃声"))
                    Button{
                        RouterManager.shared.webUrl = otherUrl.musicUrl
                        RouterManager.shared.fullPage = .web
                    }label: {
                        Text(NSLocalizedString("ringTextBody", comment: "转换成 caf 格式"))
                            .font(.footnote)
                    }
                    Text(NSLocalizedString("ringTextFooter", comment: ",时长不超过 30 秒。"))
                }
            }
            
            
            Section{
                ForEach(audioMusics.0, id: \.self) { url in
                    RingtoneItemView(audio: url,audioPlayerManager: AudioPlayerManager.shard,toastText: $toastText)
                        
                }
            }header: {
                Text(NSLocalizedString("systemRing", comment: "自带铃声"))
            }

           
        }.toast(info: $toastText)
    }
}

#Preview {
    RingtongView()
}
