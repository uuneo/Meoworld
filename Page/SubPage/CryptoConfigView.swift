//
//  CryptoConfigView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI

struct CryptoConfigView: View {
	@Environment(\.dismiss) var dismiss
	@State var toastText:String = ""
	@StateObject private var manager = ToolsManager.shared
	
	var expectKeyLength:Int {
		manager.fields.algorithm.rawValue
	}
	
	
	var body: some View {
		List {
			
			
			Section(header:Text("")){
				Picker(selection: $manager.fields.algorithm, label: Text(NSLocalizedString("cryptoConfigAlgorithm", comment: "算法"))) {
					ForEach(AESAlgorithm.allCases,id: \.self){item in
						Text(item.name).tag(item)
					}
				}
			}
			
			Section {
				Picker(selection: $manager.fields.mode, label: Text(NSLocalizedString("cryptoConfigMode", comment: "模式"))) {
					ForEach(AESMode.allCases,id: \.self){item in
						Text(item.rawValue).tag(item)
					}
				}
			}
			
			Section {
				
				HStack{
					Label {
						Text("Padding:")
					} icon: {
						Image(systemName: "space")
					}
					Spacer()
					Text(manager.fields.mode.padding)
						.foregroundStyle(.gray)
				}
				
			}
			
			Section {
				
				HStack{
					Label {
						Text("Key：")
					} icon: {
						Image(systemName: "key")
					}
					Spacer()
					
					TextEditor(text: $manager.fields.key)
						
						.overlay{
							if manager.fields.key.isEmpty{
								Text(String(format: NSLocalizedString("cryptoConfigKey", comment: "输入\(expectKeyLength)位数的key"), expectKeyLength))
									
							}
						}
						.onDisappear{
							let _ = verifyKey()
						}
						.foregroundStyle(.gray)
						.lineLimit(2)
				
					
				}
				
				
				
			}
			
			
			Section {
				
				
				HStack{
					Label {
						Text("Iv：")
					} icon: {
						Image(systemName: "dice")
					}
					Spacer()
					
					TextEditor(text: $manager.fields.iv)
						
						.overlay{
							if manager.fields.iv.isEmpty{
								Text(NSLocalizedString("cryptoConfigIv", comment: "请输入16位Iv"))
									
							}
						}
						.onDisappear{
							let _ = verifyIv()
						}
						.foregroundStyle(.gray)
						.lineLimit(2)
					
						
				}
				
				
			}
			
			
			
			HStack{
				Spacer()
				Button {
					createCopyText()
				} label: {
					Text(NSLocalizedString("cryptoConfigCopyTitle", comment: "复制发送脚本"))
						.padding(.horizontal)
					
				}.buttonStyle(BorderedProminentButtonStyle())
				
				
				
				Spacer()
			} .listRowBackground(Color.clear)
			
			
			
			
			
			
		}.navigationTitle(NSLocalizedString("cryptoConfigNavTitle", comment: "算法配置"))
			.toolbar{
				ToolbarItem {
					Button {
						if verifyKey() && verifyIv(){
							
							
							self.toastText = NSLocalizedString("cryptoConfigSuccess", comment: "验证成功")
							
							
						}
					} label: {
						Text(NSLocalizedString("cryptoConfigVerify", comment: "验证"))
					}
					
				}
			}.toast(info: $toastText)
		
	}
	func verifyKey()-> Bool{
		if manager.fields.key.count != expectKeyLength{
			manager.fields.key = ""
			self.toastText = NSLocalizedString("cryptoConfigKeyFail", comment: "Key参数长度不正确")
			return false
		}
		return true
	}
	
	func verifyIv() -> Bool{
		if manager.fields.iv.count != 16 {
			manager.fields.iv = ""
			self.toastText = NSLocalizedString("cryptoConfigIvFail", comment: "Iv参数长度不正确")
			return false
		}
		return true
	}
	
	
	func createCopyText(){
		
		if !verifyIv() {
			manager.fields.iv = AESData.generateRandomString(by32: false)
		}
		
		if !verifyKey(){
			manager.fields.key = AESData.generateRandomString(by32: expectKeyLength == 32)
		}
		
		
		
		let text = """
	 # Documentation: \(NSLocalizedString("encryptionUrl",comment: ""))
	 # python demo: 使用AES加密数据，并发送到服务器
	 # pip3 install pycryptodome
	 
	 import json
	 import base64
	 import requests
	 from Crypto.Cipher import AES
	 from Crypto.Util.Padding import pad
	 
	 
	 def encrypt_AES_CBC(data, key, iv):
	 cipher = AES.new(key, AES.MODE_\(manager.fields.mode.rawValue), iv)
	  padded_data = pad(data.encode(), AES.block_size)
	  encrypted_data = cipher.encrypt(padded_data)
	  return encrypted_data
	 
	 
	 # JSON数据
	 json_string = json.dumps({"body": "test", "sound": "birdsong"})
	 
	 # \(String(format: NSLocalizedString("keyComment",comment: ""), Int(manager.fields.algorithm.name.suffix(3))! / 8))
	 key = b"\(manager.fields.key)"
	 # \(NSLocalizedString("ivComment",comment: ""))
	 iv= b"\(manager.fields.iv)"
	 
	 # 加密
	 # \(NSLocalizedString("consoleComment",comment: "")) "\( self.createExample() )"
	 encrypted_data = encrypt_AES_CBC(json_string, key, iv)
	 
	 # 将加密后的数据转换为Base64编码
	 encrypted_base64 = base64.b64encode(encrypted_data).decode()
	 
	 print("加密后的数据（Base64编码）：", encrypted_base64)
	 
	 deviceKey = '\(MainManager.shared.servers[0].key)'
	 
	 res = requests.get(f"\(MainManager.shared.servers[0].url)/{deviceKey}/test",
	 params = {"ciphertext": encrypted_base64, "iv": iv})
	 
	 print(res.text)
	 
	 """
		
		MainManager.shared.copy(text: text)
		
		self.toastText = NSLocalizedString("copySuccessText", comment:  "复制成功")
	}
	
	func createExample()-> String{
		if let data = AESManager(manager.fields).encrypt("{\"body\": \"test\", \"sound\": \"birdsong\"}"){
			return data.base64EncodedString()
		}
		return ""
	}
	
}

#Preview {
	CryptoConfigView()
}
