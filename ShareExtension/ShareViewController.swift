//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by He Cho on 2024/10/7.
//

import UIKit
import Social
import SwiftUI
import SwiftData

class ShareViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		/// Interactive Dismiss Disabled
		isModalInPresentation = true
		
		if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
			let hostingView = UIHostingController(rootView: ShareView(itemProviders: itemProviders, extensionContext: extensionContext))
			hostingView.view.frame = view.frame
			view.addSubview(hostingView.view)
		}
	}
}

fileprivate struct ShareView: View {
	var itemProviders: [NSItemProvider]
	var extensionContext: NSExtensionContext?
	/// View Properties
	@State private var items: [Item] = []
	var body: some View {
		GeometryReader {
			let size = $0.size
			
			VStack(spacing: 15) {
				Text("Add to Favourites")
					.font(.title3.bold())
					.frame(maxWidth: .infinity)
					.overlay(alignment: .leading) {
						Button("Cancel", action: dismiss)
							.tint(.red)
					}
					.padding(.bottom, 10)
				
				ScrollView(.horizontal) {
					LazyHStack(spacing: 0) {
						ForEach(items) { item in
							Image(uiImage: item.previewImage)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.padding(.horizontal, 15)
								.frame(width: size.width)
						}
					}
				}
				.frame(height: 300)
				.scrollIndicators(.hidden)
				.scrollTargetBehavior(.paging)
				.padding(.horizontal, -15)
				
				/// Save Button
				Button(action: saveItems, label: {
					Text("Save")
						.font(.title3)
						.fontWeight(.semibold)
						.padding(.vertical, 10)
						.frame(maxWidth: .infinity)
						.foregroundStyle(.white)
						.background(.blue, in: .rect(cornerRadius: 10))
						.contentShape(.rect)
				})
				
				Spacer(minLength: 0)
			}
			.padding(15)
			.onAppear(perform: {
				extractItems(size: size)
			})
		}
	}
	
	/// Extracting Image Data and Creating Thumbnail Preview Images
	func extractItems(size: CGSize) {
		guard items.isEmpty else { return }
		DispatchQueue.global(qos: .userInteractive).async {
			for provider in itemProviders {
				let _ = provider.loadDataRepresentation(for: .image) { data, error in
					if let data, let image = UIImage(data: data), let thumbnail = image.preparingThumbnail(of: .init(width: size.width, height: 300)) {
						/// UI Must Be Updated On Main Thread
						DispatchQueue.main.async {
							items.append(.init(imageData: data, previewImage: thumbnail))
						}
					}
				}
			}
		}
	}
	
	/// Saving Items to SwiftData
	func saveItems() {
		do {
			let context = try ModelContext(.init(for: ImageItem.self))
			/// Saving Items
			for item in items {
				context.insert(ImageItem(data: item.imageData))
			}
			
			/// Saving Context
			try context.save()
			/// Closing View
			dismiss()
		} catch {
			print(error.localizedDescription)
			dismiss()
		}
	}
	
	/// Dismissing View
	func dismiss() {
		extensionContext?.completeRequest(returningItems: [])
	}
	
	private struct Item: Identifiable {
		let id: UUID = .init()
		var imageData: Data
		var previewImage: UIImage
	}
}
