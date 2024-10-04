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
    @Environment(\.dismiss) var dismiss
    @State var images:[URL] = []
    @State private var isSelect:Bool = false
    @State private var selectImageArr:[URL] = []
    @AppStorage(BaseConfig.customPhotoName) var photoCustomName:String = "FlashCat."
    @State private var showEditPhotoName:Bool = false
    
    @FocusState private var nameFieldIsFocused
    
    // 两列布局
	var columns:[GridItem]{
		if ISPAD{
			Array(repeating: GridItem(spacing: 2), count: 6)
		}else{
			Array(repeating: GridItem(spacing: 2), count: 3)
		}
	}
    @State private var alart:AlertData?

    var body: some View {
        
        VStack{
            
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
            

            
          
            
            ScrollView{
                
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(images, id: \.self){value in
                        KFImageView(value: value,column: CGFloat(columns.count), selectImageArr: $selectImageArr, isSelect: $isSelect)
                            .clipShape(RoundedRectangle(cornerRadius: 10))

                            
                    }
                }
                .padding(.horizontal, 10)
                
               
            }
            .refreshable {
                getAllImages()
            }
        }
        
       
        
       
        .onAppear{
            getAllImages()
        }
        .toolbar {
            
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    self.isSelect.toggle()
                    self.selectImageArr = []
                } label: {
                    Text( isSelect  ? NSLocalizedString("cancelBtn", comment: "取消") : NSLocalizedString("selectBtn", comment: "选择"))
                }.disabled(images.count == 0)
            }
            
            
            
            if isSelect && images.count > 2{
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if images.count == selectImageArr.count{
                            self.selectImageArr = []
                        }else{
                            self.selectImageArr = self.images
                        }
                       
                    } label: {
                        Text( images.count == selectImageArr.count ? NSLocalizedString("cancelSelectAll", comment: "取消全选") : NSLocalizedString("selectAll", comment: "全选"))
                    }
                }
            }
            
            if isSelect{
                ToolbarItem(placement: .bottomBar) {
                    HStack{
                        
                        ShareLink(items: selectImageArr.map({ value in
                            Image(uiImage: UIImage(contentsOfFile: value.path())!)
                        }), subject: Text(NSLocalizedString("imageName", comment: "图片")), message: Text(NSLocalizedString("imageName", comment: "图片"))) { value in
                            SharePreview(NSLocalizedString("imageName", comment: "图片"), image: Image(uiImage:UIImage(contentsOfFile: images.first!.path())!))
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }.disabled(selectImageArr.count == 0)
                        
                        Spacer()
                        Text( selectImageArr.count == 0 ? NSLocalizedString("selectImage", comment: "选择图片") : String(format: NSLocalizedString("selectImageCount", comment: "已选择x张图片"), selectImageArr.count))
                        Spacer()
                        Button {
                            self.alart = .init(title: NSLocalizedString("dangerHandler", comment: "危险操作！"), message: String(format: NSLocalizedString("deleteImageCount", comment: "删除x张图片"), selectImageArr.count), btn: NSLocalizedString("deleteTitle", comment: "删除"), mode: .delte)
                        } label: {
                            Image(systemName: "trash")
                        }.disabled(selectImageArr.count == 0)
                        
                        Button {
                            self.alart = .init(title: NSLocalizedString("saveImages", comment: "保存图片"), message: String(format: NSLocalizedString("saveImageCountImageNamePhoto", comment:  "保存到x张图片到 123 相册"), selectImageArr.count, photoCustomName), btn: NSLocalizedString("submitBtn", comment: "保存"), mode: .save)
                        } label: {
                            Image(systemName: "externaldrive.badge.plus")
                        }.disabled(selectImageArr.count == 0)
                    }
                }
                
            }
            
           

            
           
        }
        .alert(item: $alart) { value in
            Alert(title: Text(value.title), message: Text(value.message), primaryButton: .cancel(), secondaryButton: .destructive(Text(value.btn), action: {
                switch value.mode{
                case .delte:
                    self.deleteFile(at: self.selectImageArr)
                   
                case .save:
                    self.saveImage(self.selectImageArr)
                }
                self.isSelect.toggle()
            }))
        }
        
    }
    
    func saveImage(_ url:URL){
        guard  let image = UIImage(contentsOfFile: url.path()) else {
            
            debugPrint("ERROR:",url.absoluteString)
            return
        }
        image.bat_save(intoAlbum: "FlashCat.") { success, status in
            debugPrint(success,status)
        }
        
    }
    
    func saveImage(_ urls:[URL]){
        
        for url in urls{

            if  let image = UIImage(contentsOfFile: url.path()){
                image.bat_save(intoAlbum: self.photoCustomName) { success, status in
                    debugPrint(success,status)
                }
            }else{
                debugPrint("ERROR:",url.absoluteString)
            }
            
        }
        
        
        
    }
    
    
    
    
    func getAllImages(){
        
        var results:[URL] = []
        
        guard  let groupUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: BaseConfig.groupName),
               let cache = try? ImageCache(name: "shared", cacheDirectoryURL: groupUrl) else {
            return
        }
        
        let cacheDirectoryURL = cache.diskStorage.directoryURL
        
        // 遍历缓存目录中的文件，生成对应的URL
        if let directoryEnumerator = FileManager.default.enumerator(at: cacheDirectoryURL, includingPropertiesForKeys: nil) {
            
            for case let fileURL as URL in directoryEnumerator {
                debugPrint(fileURL)
                results.append(fileURL)
            }
           
        }
        
        self.images = results
        
        if self.images.count == 0{
            self.dismiss()
        }
        
        
#if DEBUG
        debugPrint("cache catalogue：",cacheDirectoryURL.path())
#endif
        
    }
    
    func deleteFile(at urls: [URL]) {
        //        FileManager.default?.removeItem(at: url)
        for url in urls{
            try? FileManager.default.removeItem(atPath: url.path())
            // Remove file from the list
            self.images.removeAll { $0 == url }
            
        }
        
        if images.count == 0 {
           
            self.dismiss()
        
        }
        
        
    }
}

#Preview {
    
    NavigationStack{
        ImageCacheView()
    }
    
}

struct KFImageView: View {
    var value:URL
    var column:CGFloat
    @Binding var selectImageArr:[URL]
    @Binding var isSelect:Bool
    
    var imageSize:CGSize{
		
		let width = UIScreen.main.bounds.width / column - 10;
		
		return CGSize(width: width, height: width)
      
       
    }
    
    var body: some View {
		KFImage(value)
            .aspectRatio(contentMode: .fill)
            .frame(width: imageSize.width,height: imageSize.height)
            .clipped()
			.draggable(Image(uiImage: UIImage(contentsOfFile: value.path())!))
            .overlay {
                if isSelect && selectImageArr.contains(value){
                    ZStack{
                        RoundedRectangle(cornerRadius: 0)
                            .foregroundStyle(Color.clear)
                            .background(.ultraThinMaterial.opacity(0.6))
                        VStack{
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(Color.green)
                                    .padding()
                                
                            }
                        }
                    }
                    
                }else{
                    EmptyView()
                }
                
            }
            .onTapGesture {
                if isSelect{
                    if selectImageArr.contains(value){
                        self.selectImageArr.removeAll { $0 == value }
                    }else{
                        self.selectImageArr.append(value)
                    }
                }
            }.onLongPressGesture {
                if !isSelect{
                    self.isSelect.toggle()
                    self.selectImageArr.append(value)
                }
            }
           
    }
}
