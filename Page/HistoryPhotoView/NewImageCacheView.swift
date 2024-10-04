//
//  NewImageCacheView.swift
//  Meow
//
//  Created by He Cho on 2024/10/4.
//
import SwiftUI
import Kingfisher

@available(iOS 17.0, *)
struct NewImageCacheView: View {
	@Binding var photoCustomName:String
	@Binding var images:[URL]
	@Binding var selectImageArr:[URL]
	
	@Binding var isSelect:Bool
	var columns:[GridItem]
	
	@Binding var alart:AlertData?

	
	var body: some View {
		
		VStack{
			
			ImageCacheHeaderView(photoCustomName: $photoCustomName)

			ScrollView{
				
				LazyVGrid(columns: columns, spacing: 10) {
					ForEach(images, id: \.self){value in
						KFImageView(value: value,column: CGFloat(columns.count), selectImageArr: $selectImageArr, isSelect: $isSelect)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.pinchZoom()
							
					}
				}
				.padding(.horizontal, 10)
				
			   
			}
			
		}
		
	}
	
	
	
}
