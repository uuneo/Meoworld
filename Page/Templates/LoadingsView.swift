//
//  LoadingsView.swift
//  Meow
//
//  Created by He Cho on 2024/10/4.
//
import SwiftUI


struct LoadingProgressView: ViewModifier {
	@Binding var show: Bool
	
	func body(content: Content) -> some View {
		ZStack {
			content
				.blur(radius: show ? 10 : 0)
				.disabled(show)
			
			if show {
				
				CircleLoadingView(color1: .black,color2: .black.opacity(0.8),color3: .gray , lineWidth: 10)
					.frame(width: 100, height: 100)
					.transition(.opacity)
			}
			
			
		}
		.animation(.snappy, value: show)
		
		
	}
	
}

extension View{
	func loading2(show: Binding<Bool>)-> some View{
		self.modifier(LoadingProgressView(show: show))
	}
}

struct CircleLoadingView: View {
	var color1:Color = .black
	var color2:Color = .gray
	var color3:Color = .black.opacity(0.95)
	var lineWidth: CGFloat = 20
	var rotationTime:Double = 0.4
	var animationTIME: Double = 1
	let fullRotation: Angle = .degrees(380)
	static let initialDegree:Angle = .degrees(270)
	@State var circleStart:CGFloat = 0.0
	@State var circleEnd1:CGFloat = 0.03
	@State var circleEnd2:CGFloat = 0.03
	@State var rotationDegreeA = initialDegree
	@State var rotationDegreeB = initialDegree
	@State var rotationDegreeC = initialDegree
	@State var progress:CGFloat = 0.0
	
	@State var timer:Timer?
	var body: some View {
		ZStack{
			SpinnerCircle(start: circleStart, end: circleEnd2, rotation: rotationDegreeC,lineWidth: lineWidth, color: color3)
			SpinnerCircle(start: circleStart, end: circleEnd2, rotation: rotationDegreeB,lineWidth: lineWidth, color: color2)
			SpinnerCircle(start: circleStart, end: circleEnd1, rotation: rotationDegreeA,lineWidth: lineWidth, color: color1)
		}
		.onAppear{
			self.animationSpinner()
			self.timer?.invalidate()
			self.timer = Timer.scheduledTimer(withTimeInterval: animationTIME, repeats: true){ (miniTimer) in
				self.animationSpinner()
			}
		}
		.onDisappear{
			self.timer?.invalidate()
		}
	}
	
	func animationSpinner(with duration: Double, completion: @escaping (()-> Void)){
		Timer.scheduledTimer(withTimeInterval: duration, repeats: false){ _ in
			withAnimation(Animation.easeInOut(duration: self.rotationTime)){
				completion()
			}
		}
	}
	func animationSpinner(){
		animationSpinner(with: rotationTime) { self.circleEnd1 = 1.0 }
		
		animationSpinner(with: (rotationTime * 2 ) - 0.025) {
			self.rotationDegreeA += fullRotation
			self.circleEnd2 = 0.8
		}
		
		animationSpinner(with: (rotationTime * 2)) {
			self.circleEnd1 = 0.03
			self.circleEnd2 = 0.03
		}
		
		animationSpinner(with: (rotationTime * 2) + 0.0525) {
			debugPrint(self.rotationDegreeB)
			self.rotationDegreeB += fullRotation
		}
		animationSpinner(with: (rotationTime * 2) + 0.225) {
			debugPrint(self.rotationDegreeC)
			self.rotationDegreeC += fullRotation
		}
	}
}


struct SpinnerCircle: View {
	var start:CGFloat
	var end: CGFloat
	var rotation: Angle
	var lineWidth: CGFloat = 20
	var color: Color = .pink
	
	var body: some View {
		ZStack{
			Circle()
				.trim(from: start, to: end)
				.stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
				.fill(color)
				.rotationEffect(rotation)
		}
	}
}
