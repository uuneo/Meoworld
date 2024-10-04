//
//  ImageCacheView.swift
//  Meow
//
//  Created by He Cho on 2024/8/28.
//

import SwiftUI
import Kingfisher
import PhotosUI



enum AlertType{
	case delte
	case save
}

struct AlertData:Identifiable {
	var id: UUID = UUID()
	var title:String
	var message:String
	var btn:String
	var mode:AlertType
}




struct ImageCacheView: View {
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
						
						
					}
				}
				.padding(.horizontal, 10)
				
				
			}
		}
		
		
		
	}
	
	
	
	
}


