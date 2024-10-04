//
//  ImageCacheOtherView.swift
//  Meow
//
//  Created by He Cho on 2024/10/4.
//
import SwiftUI

struct ImageCacheHeaderView: View{
	@Binding var photoCustomName:String
	@FocusState private var nameFieldIsFocused
	var body: some View{
		HStack{
			Label(NSLocalizedString("photoAlbumName", comment: "相册名"), systemImage: "photo.badge.plus")
			Spacer()
			TextField(
				   "Photo album Name",
				   text: $photoCustomName
			)
			.foregroundStyle(Color.appProfileBlue)
			.multilineTextAlignment(.trailing)
			.padding(.trailing, 30)
			.overlay {
				HStack{
					Spacer()
					Button {
						self.nameFieldIsFocused.toggle()
					} label: {
						Image(systemName: "pencil.line")
					}
					
				}
			}
			.focused($nameFieldIsFocused)
			.onChange(of: photoCustomName) { newValue in
				// 去除空格并更新绑定的文本值
				photoCustomName = newValue.trimmingCharacters(in: .whitespaces)
			}
			.toolbar {
				ToolbarItemGroup(placement: .keyboard) {
					Button("Clear") {
						self.photoCustomName = ""
					}
				   
					Spacer()
					Button("Done") {
						nameFieldIsFocused = false
					}
					
				}
			}
			
			
		   
		}.padding()
		.padding(.horizontal)
	}
	
}

