//
//  RingtoneItemView.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import SwiftUI
import AVFoundation

struct RingtoneItemView: View {
    @State var audio:URL
    @State var duration:Double = 0.0
    
    @AppStorage(BaseConfig.defaultSound, store: defaultStore) var sound:String = "silence"
    
    var name:String {
        audio.deletingPathExtension().lastPathComponent
    }
    @ObservedObject var audioPlayerManager: AudioPlayerManager
    @Binding var toastText:String
    
    var selectSound:Bool{
        sound == audio.deletingPathExtension().lastPathComponent
        
    }
    
    var body: some View{
        HStack{
            
            HStack{
                if selectSound{
                    Image(systemName: "checkmark.circle")
                        .frame(width: 35)
                        .foregroundStyle(Color.green)
                }
                
                Button{
                    audioPlayerManager.togglePlay(audioURL: audio)
                }label: {
                    VStack(alignment: .leading){
                        Text("\(name)")
                            .foregroundStyle(Color("light_dark"))
                        Text("\(formatDuration(duration))s")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
            }
            
            
            
            
            HStack{
                Spacer()
                if duration <= 30{
                    Image(systemName: "doc.on.doc")
                        .foregroundStyle(.gray)
                        .onTapGesture {
                            UIPasteboard.general.string = self.name
                            self.toastText =  NSLocalizedString("copySuccessText",comment: "")
                        }
                }else{
                    Text(NSLocalizedString("musicLong30",comment: "长度不能超过30秒"))
                        .foregroundStyle(.red)
                }
                
            }
            
            
            
            
            
        }
        .swipeActions(edge: .leading) {
            Button {
                sound = audio.deletingPathExtension().lastPathComponent
                audioPlayerManager.togglePlay(audioURL: audio)
            } label: {
                Text("选择")
            }
            
        }
        
        .task {
            do {
                let duration = try await loadVideoDuration(fromURL: self.audio)
                self.duration =  duration
                
                
            } catch {
#if DEBUG
                print("Error loading video duration: \(error.localizedDescription)")
#endif
                
            }
        }.navigationTitle(NSLocalizedString("allSounds",comment: ""))
        
        
    }
    
}

extension RingtoneItemView{
    // 定义一个异步函数来加载audio的持续时间
    func loadVideoDuration(fromURL videoURL: URL) async throws -> Double {
        // 创建一个AVPlayer实例
        let player = AVAsset(url: videoURL)
        
        // 使用async/await来加载持续时间
        let duration = try await player.load(.duration)
        
        // 计算并返回持续时间（以秒为单位）
        let durationInSeconds = CMTimeGetSeconds(duration)
        return durationInSeconds
    }
    
    
    func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: duration)) ?? ""
    }
    
}

