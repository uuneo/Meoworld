//
//  AudioPlayerManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation
import AVFoundation

class AudioPlayerManager: ObservableObject{
    static let shard = AudioPlayerManager()
    
    private init() {}
    
    @Published var currentlyPlayingURL: URL?
    private var audioPlayer: AVAudioPlayer?
    
    
    func togglePlay(audioURL: URL) {
        if let currentlyPlayingURL = currentlyPlayingURL, currentlyPlayingURL == audioURL {
            stop()
        } else {
            play(audioURL)
        }
    }
    
    func play(_ audioURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.play()
            currentlyPlayingURL = audioURL
        } catch {
#if DEBUG
            print("playFail: \(error)")
#endif
            
        }
    }
    
    func stop() {
        audioPlayer?.stop()
        currentlyPlayingURL = nil
    }
    
    func writeToLibrarySoundsDirectory() {
        // 获取 Library 目录
        guard let libraryDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
#if DEBUG
            print("Failed to get Library directory.")
#endif
            
            return
        }
        
        // 创建 /Library/Sounds 目录的路径
        let soundsDirectory = libraryDirectory.appendingPathComponent("Sounds")
        
        // 检查 /Library/Sounds 目录是否存在，如果不存在则创建
        do {
            try FileManager.default.createDirectory(at: soundsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
#if DEBUG
            print("Error creating Sounds directory: \(error)")
#endif
           
            return
        }
        
        // 要写入的文件路径
        let fileURL = soundsDirectory.appendingPathComponent("example.txt")
        // 写入文件
        let contents = "Hello, this is a test file."
        do {
            try contents.write(to: fileURL, atomically: true, encoding: .utf8)
#if DEBUG
            print("File written successfully.")
#endif
            
        } catch {
            
#if DEBUG
            print("Error writing file: \(error)")
#endif
            
           
        }
    }
    
    /// 将指定文件保存在 Library/Sound，如果存在则覆盖
    func saveSound(url: URL) {
        if  let soundsDirectoryUrl = getSoundsDirectory() {
            let soundUrl = soundsDirectoryUrl.appendingPathComponent(url.lastPathComponent)
            do{
                // 如果文件已存在，先尝试删除
                if FileManager.default.fileExists(atPath: soundUrl.path) {
                    try FileManager.default.removeItem(at: soundUrl)
                }
                
                try FileManager.default.copyItem(at: url, to: soundUrl)
            }catch{
#if DEBUG
                print(error)
#endif
               
            }
        }
       
    }

    func deleteSound(url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    /// 获取 Library 目录下的 Sounds 文件夹
    /// 如果不存在就创建
    func getSoundsDirectory() -> URL? {
        // 获取音频文件夹路径
        if let soundFolderPath = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first?.appendingPathComponent("Sounds"){
            // 检查文件夹是否存在
            var isDirectory: ObjCBool = false
            if !FileManager.default.fileExists(atPath: soundFolderPath.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
                // 如果文件夹不存在，则创建它
                do {
                    try FileManager.default.createDirectory(at: soundFolderPath, withIntermediateDirectories: true, attributes: nil)
#if DEBUG
                    print("音频文件夹已创建：\(soundFolderPath)")
#endif
                   
                } catch {
#if DEBUG
                    print("无法创建音频文件夹：\(error)")
#endif
                    
                }
            }
            return soundFolderPath
        }
       return nil
    }
    
    
    func listFilesInDirectory() -> ([ URL],[URL]) {
        let urls:[URL] = {
            var temurl = Bundle.main.urls(forResourcesWithExtension: "caf", subdirectory: nil) ?? []
            temurl.sort { u1, u2 -> Bool in
                u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
            }
            return temurl
        }()
        
        let customSounds: [URL] = {
            guard let soundsDirectoryUrl = getSoundsDirectory() else{
#if DEBUG
                print("铃声获取失败")
#endif
              
                return []
            }
            
            var urlemp = self.getFilesInDirectory(directory: soundsDirectoryUrl.path(), suffix: "caf")
            urlemp.sort { u1, u2 -> Bool in
                u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
            }

            return urlemp
        }()
        
        return (urls,customSounds)
    }
    
    
    /// 返回指定文件夹，指定后缀的文件列表数组
    func getFilesInDirectory(directory: String, suffix: String) -> [URL] {
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(atPath: directory)
            return files.compactMap { file -> URL? in
                if file.hasSuffix(suffix) {
                    return URL(fileURLWithPath: directory).appendingPathComponent(file)
                }
                return nil
            }
        } catch {
            return []
        }
    }
    
   static func stopCallNotificationProcessor() {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFNotificationName(BaseConfig.kStopCallProcessorKey as CFString), nil, nil, true)
    }
    
}
