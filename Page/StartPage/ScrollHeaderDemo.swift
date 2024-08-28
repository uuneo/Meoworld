//
//  ScrollHeaderDemo.swift
//  Meow
//
//  Created by He Cho on 2024/8/26.
//

import SwiftUI
import ScalingHeaderScrollView

struct ScrollHeaderDemo: View {
    @Environment(\.presentationMode) var presentationMode

    @State var progress: CGFloat = 0

    private let minHeight = 110.0
    private let maxHeight = 500.0
    
    @Namespace private var avatarSpace

    var body: some View {
        ZStack{
            ScalingHeaderScrollView {
                ZStack {
                    Color.white.edgesIgnoringSafeArea(.all)
                    largeHeader(progress: progress)
                }
            } content: {
                GeometryReader(content: { geometry in
                    Text("Content\(geometry.frame(in: .global).minY)")
                })
                
                VStack{
                    Text("↓ Pull to refresh ↓\(progress)")
                    ForEach(0...1000,id: \.self){value in
                        
                        Text("↓ Pull to refresh ↓")
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
               
            }
            .height(min: minHeight, max: maxHeight)
            .collapseProgress($progress)
            .allowsHeaderGrowth()
            .ignoresSafeArea()
            
            topButtons
        
        }
    }
    
    private var topButtons: some View {
        VStack {
            HStack {
                Button("", action: { self.presentationMode.wrappedValue.dismiss() })
                    .buttonStyle(CircleButtonStyle(imageName: "arrow.backward"))
                    .padding(.leading, 17)
                    .padding(.top, 50)
                    
                Spacer()
                Button("", action: { print("Info") })
                    .buttonStyle(CircleButtonStyle(imageName: "ellipsis"))
                    .padding(.trailing, 17)
                    .padding(.top, 50)
            }
            Spacer()
        }
        .ignoresSafeArea()
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        ZStack {
            Image("profileAvatar")
                .resizable()
                .scaledToFill()
                .frame(height: maxHeight)
                .opacity(1 - progress)
//                .matchedGeometryEffect(id: "123", in: avatarSpace,isSource: false)
            
            VStack {
                Spacer()
                
//                HStack(spacing: 4.0) {
//                    Capsule()
//                        .frame(width: 40.0, height: 3.0)
//                        .foregroundColor(.white)
//                    
//                    Capsule()
//                        .frame(width: 40.0, height: 3.0)
//                        .foregroundColor(.white.opacity(0.2))
//                    
//                    Capsule()
//                        .frame(width: 40.0, height: 3.0)
//                        .foregroundColor(.white.opacity(0.2))
//                }
                
                ZStack(alignment: .leading) {

                    VisualEffectView(effect: UIBlurEffect(style: .regular))
                        .mask(Rectangle().cornerRadius(40, corners: [.topLeft, .topRight]))
                        .offset(y: 10.0)
                        .frame(height: 80.0)

                    RoundedRectangle(cornerRadius: 40.0, style: .circular)
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.white.opacity(0.0), .white]), startPoint: .top, endPoint: .bottom)
                        )

                    Text("123")
                        .fontBold(color: .appDarkGray, size: 24)
                        .padding(.leading, 24.0)
                        .padding(.top, 10.0)
                        .opacity(progress > 0.8 ? 0 : 1 - progress)
                        .animation(.easeInOut, value: progress)
                        .offset(x: progress > 0.8 ? 100 : 0)
                    smallHeader
                        .padding(.leading, 85.0)
//                        .opacity(progress)
                        .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
                        .animation(.easeInOut, value: progress)
                }
                .frame(height: 80.0)
            }
        }
    }
    

    
    private var smallHeader: some View {
        HStack(spacing: 12.0) {
            Image("profileAvatar")
                .resizable()
                .frame(width: 40.0, height: 40.0)
                .clipShape(RoundedRectangle(cornerRadius: 6.0))

            Text("123")
                .fontRegular(color: .appDarkGray, size: progress > 0.9 ? 17 : 24)
                .offset(x: progress > 0.8 ? 0 : -100)
             
        }
    }

}

#Preview {
    ScrollHeaderDemo()
}


struct HireButtonStyle: ButtonStyle {

    var foreground = Color.white

    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.hex("#374BFE"))
            .overlay(configuration.label.foregroundColor(foreground))
    }
}

struct VisualEffectView: UIViewRepresentable {

    var effect: UIVisualEffect?

    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

extension View {

    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
