//
//  AudioPlayerManager.swift
//  Meow
//
//  Created by He Cho on 2024/8/9.
//

import Foundation
import AVKit
import Combine


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






enum PlaybackMode {
	case singleLoop     // 单曲循环
	case sequential     // 顺序播放
	case shuffle        // 随机播放
	case close
}


final class AvManager: ObservableObject{
	
	static let shared = AvManager()
	private init() {
		self.updateMusics()
		self.setupNotificationObserver()
	}
	
	@Published var musics: [URL] = []
	@Published var examples:[URL] = []
	@Published var currentlyPlayingURL: URL?
	@Published var isPlaying:Bool = false
	@Published var currentTime: TimeInterval = 0.0
	@Published var totalTime: TimeInterval = 0.0
	@Published var songTitle:String = ""
	@Published var artistName:String = ""
	@Published var albumArtwork:UIImage = UIImage(named: "music")!
	
	@Published var volume:Float = 0.5
	@Published var playBackMode:PlaybackMode = .sequential
	
	private var timer:Timer?
	
	private var timerOff:Timer?
	
	private var player: AVPlayer?
	
	deinit{
		if let timer { timer.invalidate() }
		if let timerOff { timerOff.invalidate() }
	}
	
	var icon:String{
		isPlaying ?  "pause.fill" : "play"
	}
	
	
	var playTypeIcon:String{
		switch playBackMode {
		case .singleLoop:
			"repeat.1"
		case .sequential:
			"repeat"
		case .shuffle:
			"shuffle"
		case .close:
			"gobackward.minus"
		}
	}
	
	var totalTimeStr:String{
		
		let ses = currentTime - totalTime
		
		let minute = Int(ses / 60)
		let secound = abs(Int(ses) % 60)
		
		return String(format: "%02d:%02d", minute, secound)
	}
	
	var currentTimeStr:String{
		let minute = Int(currentTime / 60)
		let secound = Int(currentTime) % 60
		return String(format: "%02d:%02d", minute, secound)
	}
	
	
	func changeIcon(){
		switch playBackMode {
		case .singleLoop:
			self.playBackMode = .sequential
		case .sequential:
			self.playBackMode = .shuffle
		case .shuffle:
			self.playBackMode = .close
		case .close:
			self.playBackMode = .singleLoop
		}
	}
	
	
	func setCurrentTime(currentTime: Double){
		self.currentTime = currentTime
		guard let player = self.player else { return }
		
		player.seek(to: CMTime(seconds: currentTime, preferredTimescale: 600))
		
	}
	
	func volumeData(volume: Float = 0.0) -> Float?{
		
		guard let player = self.player else { return nil }
		
		if volume.isZero{
			self.volume = player.volume
		}else{
			self.volume = volume
			player.volume = volume
		}
		return self.volume
	}
	
	
	func getMetaData(){
		guard let player = self.player else { return }
		
		Task{
			
			
			do{
				guard let currentItem = player.currentItem else { return }
				let metaData = try await currentItem.asset.load(.metadata)
				
				debugPrint("\(metaData)")
				
				// 获取歌曲名（title）
				if let titleMetadata = metaData.first(where: {$0.commonKey == .commonKeyTitle}),
				   let data = try await titleMetadata.load(.stringValue)
				{
					
					
					DispatchQueue.main.async {
						self.songTitle =  data
					}
					
				}else{
					DispatchQueue.main.async {
						self.songTitle =  self.currentlyPlayingURL?.deletingPathExtension().lastPathComponent ?? "Unknown Title"
						
					}
				}
				
				// 获取艺术家名（artist）
				if let artistMetadata = metaData.first(where: { $0.commonKey == .commonKeyArtist }),
				   let data = try await artistMetadata.load(.stringValue)
				{
					
					DispatchQueue.main.async{
						self.artistName = data
					}
					
				}else{
					DispatchQueue.main.async {
						self.artistName =  "Unknown Artist"
					}
				}
				
				
				// 获取专辑图片（album artwork）
				if let artworkMetadata = metaData.first(where: { $0.commonKey == .commonKeyArtwork }),
				   let data = try await artworkMetadata.load(.value) as? Data,
				   let artworkImage = UIImage(data: data)
				{
					DispatchQueue.main.async {
						self.albumArtwork = artworkImage
					}
				}else{
					if let data = UIImage(named: "music"){
						DispatchQueue.main.async {
							self.albumArtwork = data
						}
					}
					
				}
				
			}catch{
				debugPrint(error.localizedDescription)
			}
			
			
		}
		
		
	}
	
	
	
	func play(url: URL? = nil) -> Bool{
		
		var audioUrl:URL?
		
		if let url = url {
			audioUrl = url
		}else{
			if musics.isEmpty  {
				self.musics = listFilesInDirectory()
			}
			
			if !musics.isEmpty {
				audioUrl =  musics.first
			}
			
		}
		
		guard let audioUrl = audioUrl else { return false }
		
		
		if self.currentlyPlayingURL == audioUrl {
			//  处理正在播放中，或者暂停
			
			guard  let player = self.player else { return  false}
			
			if self.isPlaying && currentTime != 0.0 {
				debugPrint("暂停")
				player.pause()
				self.isPlaying = false
				return true
				
			}else{
				debugPrint("播放")
				player.play()
				self.isPlaying = true
				return true
				
			}
		}else{
			
			// 处理新播放事件
			if self.currentlyPlayingURL != nil { self.stop() }
			
			self.currentlyPlayingURL = audioUrl
			self.player = AVPlayer(url: audioUrl)
			
			self.setupPlayerTime()
			
			guard let player = self.player else { return false}
			
			self.getMetaData()
			
			player.play()
			
			
			self.isPlaying = true
			_ = self.volumeData(volume: self.volume)
			return true
			
		}
		
	}
	
	private func stop(){
		if let timer { timer.invalidate() }
		if let timerOff { timerOff.invalidate() }
		self.currentlyPlayingURL = nil
		self.currentTime = .zero
		self.totalTime = .zero
		self.currentlyPlayingURL = nil
		self.player = nil
		self.isPlaying = false
	}
	
	private func setupPlayerTime(){
		if let timer { timer.invalidate() }
		
		guard let player else{ return }
		
		if let currentItem = player.currentItem{
			Task{
				do{
					let temTime = try await  currentItem.asset.load(.duration)
					DispatchQueue.main.async{
						self.totalTime = CMTimeGetSeconds(temTime)
					}
				}catch{
					print(error.localizedDescription)
				}
			}
			
			
		}
		
		let timer1 = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
			let temTime = CMTimeGetSeconds( player.currentTime())
			if temTime != self.currentTime{
				self.currentTime = temTime.isNaN ? 0.0 : temTime
				_ = self.volumeData()
			}
		}
		
		
		
		
		
		timer1.fire()
		
		self.timer = timer1
	}
	
	func next(_ next:Bool = true, auto:Bool = false) -> Bool{
		
		var audioUrl:URL?
		
		func _abc(_ next:Bool) -> URL?{
			guard !self.musics.isEmpty,
				  let currentIndex = musics.firstIndex(where: { $0 == self.currentlyPlayingURL }) else {
				return nil
			}
			if next {
				let nextIndex = currentIndex + 1 >= musics.count ? 0 : currentIndex + 1
				return  musics[nextIndex]
			}else{
				let previousIndex = currentIndex - 1 < 0 ? musics.count - 1 : currentIndex - 1
				return musics[previousIndex]
			}
		}
		
		switch playBackMode {
		case .singleLoop:
			audioUrl =	self.currentlyPlayingURL
			self.setCurrentTime(currentTime: 0.0)
			
			
		case .sequential:
			audioUrl = _abc(next)
		case .shuffle:
			
			guard !musics.isEmpty else { return false }
			
			if self.musics.count > 1{
				while true {
					let data = musics.randomElement()
					if self.currentlyPlayingURL != data {
						audioUrl = data
						break
					}
				}
			}
			
			
		case .close:
			if auto{
				self.stop()
				return false
			}else{
				audioUrl = _abc(next)
			}
			
		}
		
		return self.play(url:  audioUrl)
	}
	
	func listFilesInDirectory(_ auto:Int = 0) -> [URL]{
		switch auto{
		case 0:
			let urls = getExampleList()
			let customSounds = getCustomList()
			return  customSounds.count > 0 ? customSounds : urls
		case 1:
			return getExampleList()
		case 2:
			return getCustomList()
		default:
			return getExampleList() + getCustomList()
		}
		func getCustomList()-> [URL]{
			guard let soundsDirectoryUrl = getSoundsDirectory() else{
				return []
			}
			
			var urlemp = self.getAudioFilesInDirectory(directory: soundsDirectoryUrl.path())
			urlemp.sort { u1, u2 -> Bool in
				u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
			}
			
			return urlemp
		}
		
		func getExampleList() -> [URL]{
			var temurl = Bundle.main.urls(forResourcesWithExtension: "mp3", subdirectory: nil) ?? []
			temurl.sort { u1, u2 -> Bool in
				u1.lastPathComponent.localizedStandardCompare(u2.lastPathComponent) == ComparisonResult.orderedAscending
			}
			return temurl
		}
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
	
	func getAudioFilesInDirectory(directory: String) -> [URL] {
		let fileManager = FileManager.default
		let audioExtensions = ["mp3", "wav", "m4a", "flac", "aac", "ogg"] // 音频文件的扩展名列表
		
		do {
			let files = try fileManager.contentsOfDirectory(atPath: directory)
			return files.compactMap { file -> URL? in
				let fileURL = URL(fileURLWithPath: directory).appendingPathComponent(file)
				// 过滤音频文件
				if audioExtensions.contains(fileURL.pathExtension.lowercased()) {
					return fileURL
				}
				return nil
			}
		} catch {
			return []
		}
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
	
	/// 监听播放结束的通知
	func setupNotificationObserver() {
		NotificationCenter.default.addObserver(
			forName: .AVPlayerItemDidPlayToEndTime,
			object: player?.currentItem,
			queue: .main
		) { _ in
			_ = self.next(auto: true)
		}
		
	}
	
	
	
}


extension AvManager{
	
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
				debugPrint("保存成功", soundUrl)
				self.updateMusics()
			}catch{
#if DEBUG
				print(error.localizedDescription)
#endif
				
			}
		}
		
	}
	
	
	func deleteSound(url: URL) {
		do{
			try FileManager.default.removeItem(at: url)
		}catch{
			debugPrint(error.localizedDescription)
		}
		
	}
	
	func updateMusics(){
		self.musics = self.listFilesInDirectory()
		self.examples = self.listFilesInDirectory(1)
	}
	
	
	func setupAudioSession() {
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
			try AVAudioSession.sharedInstance().setActive(true)
			
			// 监听音频中断的通知
			NotificationCenter.default.addObserver(self,
												   selector: #selector(handleInterruption),
												   name: AVAudioSession.interruptionNotification,
												   object: nil)
		} catch {
			print("音频会话配置失败: \(error.localizedDescription)")
		}
	}
	
	@objc func handleInterruption(notification: Notification) {
		guard let userInfo = notification.userInfo,
			  let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
			  let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
			return
		}
		
		if type == .began {
			// 音频中断开始（例如来电）
			print("音频中断123")
		} else if type == .ended {
			// 音频中断结束
			print("音频中断结束")
			// 恢复播放
			if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
				let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
				if options.contains(.shouldResume) {
					// 如果中断结束后应该恢复播放
					// player.play() // 恢复播放
					player?.play()
				}
			}
		}
	}
	
}
