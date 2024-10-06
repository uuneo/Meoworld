//
//  SignInView.swift
//  Meow
//
//  Created by He Cho on 2024/8/10.
//

import SwiftUI

struct SignInView: View {
    @Environment(\.dismiss) var dismiss
	@EnvironmentObject private var manager:MainManager
	
    @State private var emailName:String = ""
    @State private var codeNumber:String = ""
    @State private var isCountingDown:Bool = false
    
    @State private var appear = [false, false, false]
    @State private var circleInitialY:CGFloat = CGFloat.zero
    @State private var circleY:CGFloat = CGFloat.zero
    
    @State private var countdown:Int = 180
    @FocusState private var isPhoneFocused: Bool
    @FocusState private var isCodeFocused: Bool
	
    @StateObject private var router = RouterManager.shared
    
    @State private var selectServerIndex:Int = 0
    @State private var loadingText:String = ""
	let timer: DispatchSourceTimer = DispatchSource.makeTimerSource()

    var filedColor:Color{
		emailName.isValidEmail() ? .blue : .red
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack{
                Text(NSLocalizedString("signTitle", comment: "通知"))
                    .font(.largeTitle).bold()
                    .blendMode(.overlay)
                    .slideFadeIn(show: appear[0], offset: 30)
                Spacer()
               
                Picker(selection: $selectServerIndex, label: Text("")) {
                    
                    ForEach(manager.servers.indices, id: \.self){index in
                        let item = manager.servers[index]
                        Text(item.url.removeHTTPPrefix()).tag(index)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
            
            Text(NSLocalizedString("signSubTitle", comment: "替换key为email"))
                .padding(.leading)
                .font(.headline)
                .foregroundStyle(.secondary)
                .slideFadeIn(show: appear[1], offset: 20)
            
            form.slideFadeIn(show: appear[2], offset: 10)
            
            Divider()
            
            HStack{
                Text(NSLocalizedString("signHelp", comment: "不知道如何开始? **获取帮助**"))
                    .font(.footnote)
                    .foregroundColor(.primary.opacity(0.7))
                    .accentColor(.primary.opacity(0.7))
                    .onTapGesture {
                        router.webUrl = otherUrl.helpRegisterWebUrl
                        router.fullPage = .web
                    }
                Spacer()
                if self.countdown != 180{
                    Button(action: {
                        self.countdown = 0
                        self.codeNumber = ""
                        self.isCodeFocused = false
                        self.isCountingDown = false
            
                    }) {
                        Text(NSLocalizedString("signRetry", comment: "**重试**"))
                    }
                }
                
     
            }
            
            
           
        }
        .coordinateSpace(name: "stack")
        .padding(20)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .backgroundColor(opacity: 0.4)
        .cornerRadius(30)
        .background(
            VStack {
                Circle().fill(.blue).frame(width: 68, height: 68)
                    .offset(x: 0, y: circleY)
                    .scaleEffect(appear[0] ? 1 : 0.1)
            }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        )
        .modifier(OutlineModifier(cornerRadius: 30))
        .onAppear { animate() }
        .onChange(of: isCountingDown) { value in
            if value{
				self.startCountdown()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
					self.isPhoneFocused.toggle()
					self.isCodeFocused.toggle()
				}
            }
        }
        

    }
    
    var form: some View {
        Group{
            
            
            TextField(NSLocalizedString("signPhoneInput", comment: "请输入邮件地址"), text: $emailName)
                .textContentType(.flightNumber)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundStyle(.lightDark)
                .customField(
                    icon: "envelope.fill"
                )
                .foregroundStyle(filedColor)
				.overlay(
					GeometryReader { proxy in
						let offset = proxy.frame(in: .named("stack")).minY + 32
						Color.clear.preference(key: CirclePreferenceKey.self, value: offset)
						
					}
						.onPreferenceChange(CirclePreferenceKey.self) { value in
							circleInitialY = value
							circleY = value
						}
				)
				.focused($isPhoneFocused)
				.onChange(of: isPhoneFocused) {value in
					if value {
						withAnimation {
                            circleY = circleInitialY
                        }
                    }
                }
                .onTapGesture {
                    self.isPhoneFocused = true
                }
                .disabled(isCountingDown)
            
            if isCountingDown{
                TextField(NSLocalizedString("signCodeInput", comment: "请输入验证码"), text: $codeNumber)
                    .keyboardType(.numberPad)
                    .customField(icon: "key.fill")
                    .focused($isCodeFocused)
                    .onChange(of: isCodeFocused) {value  in
                        if value {
                            withAnimation {
                                circleY = circleInitialY + 70
                            }
                        }
                    }
                    .onTapGesture {
                        self.isCodeFocused = true
                    }
                    .overlay {
                        Text("\(countdown)")
                            .frame(maxWidth: .infinity,alignment: .trailing)
                            .opacity(isCountingDown ? 1 : 0)
                            .font(.headline)
                            .foregroundStyle(Color.red)
                            .animation(.bouncy, value:countdown)
                            .padding(.trailing, 10)
                    }
                    
            }
            
           
            
            
            AngularButton(title: !isCountingDown ? NSLocalizedString("signGetCode", comment: "获取验证码") : NSLocalizedString("register", comment: "注册"), disable: !isCountingDown ? !emailName.isValidEmail() : codeNumber.count == 0,loading: loadingText ){
                if !isCountingDown{
                    self.loadingText = "正在获取验证码"
                    Task{
                        let (success, msg) = await self.sendCode(self.emailName)
                        if success {
							await MainActor.run {
								isCountingDown.toggle()
							}
                          
                        }else{
							await MainActor.run {
                                self.loadingText = msg ?? "其他错误"
                            }
                        }
						try? await Task.sleep(nanoseconds: Uint64Seconds(0.5))
						await MainActor.run {
                            self.loadingText = ""
                        }
                        
                    }
                }else{
                    self.loadingText = "正在切换key"
                    Task{
                        
                        let (success, msg) = await self.register(email: emailName, code: codeNumber)
						await MainActor.run {
							if success {
								var result =   manager.servers[selectServerIndex]
								
								result.key = emailName
								
								manager.servers[selectServerIndex] = result
								
								dismiss()
							}else{
								self.loadingText = msg ?? "其他错误"
							}
						}
						
						try? await Task.sleep(nanoseconds: Uint64Seconds(0.5))
						await MainActor.run {
							self.loadingText = ""
						}
					}
					
				}
            }
            
            
        }
        
        
    }
    
	func startCountdown() {
		isCountingDown = true
		countdown = 180
		
		timer.schedule(deadline: .now(), repeating: 1.0)
		
		timer.setEventHandler {
			
			if self.countdown > 0 {
				self.countdown -= 1
			} else {
				self.timer.cancel()
				self.isCountingDown = false
				self.countdown = 180
			}
		}
		
		timer.resume()
	}
    
    func animate() {
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.2)) {
            appear[0] = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.4)) {
            appear[1] = true
        }
        withAnimation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8).delay(0.6)) {
            appear[2] = true
        }
    }
    
    func sendCode(_ email:String) async -> (Bool,String?) {
        let server = manager.servers[selectServerIndex]
        
        do{
            let res:baseResponse<String>? = try await NetworkManager.shared.fetch( "\(server.url)/sendCode?email=\(email)&key=\(server.key)")
            return (res?.code == 200, res?.message)
        }catch{
            return (false,"发生错误")
        }
    }
    func register(email:String, code:String) async -> (Bool,String?) {
        let server = manager.servers[selectServerIndex]
        
        do{
            let res:baseResponse<DeviceInfo>? = try await NetworkManager.shared.fetch("\(server.url)/keyWithEmail?email=\(email)&code=\(codeNumber)&key=\(server.key)&deviceToken=\(manager.deviceToken)")
            return (res?.code == 200, res?.message)
        }catch{
            return (false,"发生错误")
        }
       
    }
}

#Preview {
    SignInView()
}
