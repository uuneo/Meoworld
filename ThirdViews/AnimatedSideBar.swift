//
//  AnimatedSideBar.swift
//  Meow
//
//  Created by He Cho on 2024/10/7.

///struct ExampleAnimatedView: View {
///	/// View Properties
///	@State private var showMenu: Bool = false
///	@State private var rotateWhenExpands: Bool = true
///	@State private var disablesInteractions: Bool = false
///	@State private var disableCorners: Bool = false
///	var body: some View {
///		AnimatedSideBar(
///			rotatesWhenExpands: rotateWhenExpands,
///			disablesInteraction: disablesInteractions,
///			sideMenuWidth: 200,
///			cornerRadius: disableCorners ? 0 : 25,
///			showMenu: $showMenu
///		) { safeArea in
///			NavigationStack {
///				List {
///					NavigationLink("Detail View") {
///						Text("Hello iJustine")
///							.navigationTitle("Detail")
///					}
///
///					Section("Customization") {
///						Toggle("Rotates When Expands", isOn: $rotateWhenExpands)
///						Toggle("Disables Interactions", isOn: $disablesInteractions)
///						Toggle("Disables Corners", isOn: $disableCorners)
///					}
///				}
///				.navigationTitle("Home")
///				.toolbar {
///					ToolbarItem(placement: .topBarLeading) {
///						Button(action: { showMenu.toggle() }) {
///							Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
///								.foregroundStyle(Color.primary)
///								.contentTransition(.symbolEffect)
///						}
///					}
///				}
///			}
///		} menuView: { safeArea in
///			SideBarMenuView(safeArea)
///		} background: {
///			Rectangle()
///				.fill(.black)
///		}
///	}
///
///	@ViewBuilder
///	func SideBarMenuView(_ safeArea: UIEdgeInsets) -> some View {
///		VStack(alignment: .leading, spacing: 12) {
///		   Text("Side Menu")
///				.font(.largeTitle.bold())
///				.padding(.bottom, 10)
///
///			SideBarButton(.home)
///			SideBarButton(.bookmark)
///			SideBarButton(.favourites)
///			SideBarButton(.profile)
///
///			Spacer(minLength: 0)
///
///			SideBarButton(.logout)
///		}
///		.padding(.horizontal, 15)
///		.padding(.vertical, 20)
///		.padding(.top, safeArea.top)
///		.padding(.bottom, safeArea.bottom)
///		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
///		.environment(\.colorScheme, .dark)
///	}
///
///	@ViewBuilder
///	func SideBarButton(_ tab: Tab, onTap: @escaping () -> () = {  }) -> some View {
///		Button(action: onTap, label: {
///			HStack(spacing: 12) {
///				Image(systemName: tab.rawValue)
///					.font(.title3)
///
///				Text(tab.title)
///					.font(.callout)
///
///				Spacer(minLength: 0)
///			}
///			.padding(.vertical, 10)
///			.contentShape(.rect)
///			.foregroundStyle(Color.primary)
///		})
///	}
///
///	/// Sample Tab's
///	enum Tab: String, CaseIterable {
///		case home = "house.fill"
///		case bookmark = "book.fill"
//		case favourites = "heart.fill"
//		case profile = "person.crop.circle"
//		case logout = "rectangle.portrait.and.arrow.forward.fill"
//		
//		var title: String {
//			switch self {
//			case .home: return "Home"
//			case .bookmark: return "Bookmark"
//			case .favourites: return "Favourites"
//			case .profile: return "Profile"
//			case .logout: return "Logout"
//			}
//		}
//	}
//}

import SwiftUI

struct AnimatedSideBar<Content: View, MenuView: View, Background: View>: View {
	/// Customization Options
	var rotatesWhenExpands: Bool = true
	var disablesInteraction: Bool = true
	var sideMenuWidth: CGFloat = 200
	var cornerRadius: CGFloat = 25
	@Binding var showMenu: Bool
	@ViewBuilder var content: (UIEdgeInsets) -> Content
	@ViewBuilder var menuView: (UIEdgeInsets) -> MenuView
	@ViewBuilder var background: Background
	/// View Properties
	@GestureState private var isDragging: Bool = false
	@State private var offsetX: CGFloat = 0
	@State private var lastOffsetX: CGFloat = 0
	/// Used to Dim Content View When Side Bar is Being Dragged
	@State private var progress: CGFloat = 0
	var body: some View {
		GeometryReader {
			let size = $0.size
			let safeArea = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow?.safeAreaInsets ?? .zero
			
			HStack(spacing: 0) {
				GeometryReader { _ in
					menuView(safeArea)
				}
				.frame(width: sideMenuWidth)
				/// Clipping Menu Interaction Beyond it's Width
				.contentShape(.rect)
				
				GeometryReader { _ in
					content(safeArea)
				}
				.frame(width: size.width)
				.overlay {
					if disablesInteraction && progress > 0 {
						Rectangle()
							.fill(.black.opacity(progress * 0.2))
							.onTapGesture {
								withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
									reset()
								}
							}
					}
				}
				.mask {
					RoundedRectangle(cornerRadius: progress * cornerRadius)
				}
				.scaleEffect(rotatesWhenExpands ? 1 - (progress * 0.1) : 1, anchor: .trailing)
				.rotation3DEffect(
					.init(degrees: rotatesWhenExpands ? (progress * -15) : 0),
					axis: (x: 0.0, y: 1.0, z: 0.0)
				)
			}
			.frame(width: size.width + sideMenuWidth, height: size.height)
			.offset(x: -sideMenuWidth)
			.offset(x: offsetX)
			.contentShape(.rect)
			.simultaneousGesture(dragGesture)
		}
		.background(background)
		.ignoresSafeArea()
		.onChange(of: showMenu, initial: true) { oldValue, newValue in
			withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
				if newValue {
					showSideBar()
				} else {
					reset()
				}
			}
		}
	}
	
	/// Drag Gesture
	var dragGesture: some Gesture {
		DragGesture()
			.updating($isDragging) { _, out, _ in
				out = true
			}.onChanged { value in
				/// Sometimes Gesture is being called when the host contains any Horizontal ScrollView, Usage of DispatchQueue avoids those cases.
				DispatchQueue.main.asyncAfter(deadline: .now()) {
					guard value.startLocation.x > 10, isDragging else { return }
					
					let translationX = isDragging ? max(min(value.translation.width + lastOffsetX, sideMenuWidth), 0) : 0
					offsetX = translationX
					calculateProgress()
				}
			}.onEnded { value in
				guard value.startLocation.x > 10 else { return }
				
				withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
					let velocityX = value.velocity.width / 8
					let total = velocityX + offsetX
					
					if total > (sideMenuWidth * 0.5) {
						showSideBar()
					} else {
						reset()
					}
				}
			}
	}
	
	/// Show's Side Bar
	func showSideBar() {
		offsetX = sideMenuWidth
		lastOffsetX = offsetX
		showMenu = true
		calculateProgress()
	}
	
	/// Reset's to it's Initial State
	func reset() {
		offsetX = 0
		lastOffsetX = 0
		showMenu = false
		calculateProgress()
	}
	
	/// Convert's Offset into Series of progress ranging from 0 - 1
	func calculateProgress() {
		progress = max(min(offsetX / sideMenuWidth, 1), 0)
	}
}
