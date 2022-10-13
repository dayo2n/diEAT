//
//  EditPostView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/13.
//

import SwiftUI
import Kingfisher

struct EditPostView: View {
    
    @State var editMode: Bool // true: 수정모드, false: 새 글 작성 모드
    @Binding var editPostMode: Bool
    
    @State private var imagePickMode: Bool = false
    @State private var selectedImage: UIImage?
    @State private var image: Image?
    
    @State private var caption: String = ""
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel: PostViewModel = PostViewModel()
    
    var body: some View {
        VStack {
            ZStack {
                if image == nil {
                    Rectangle()
                        .frame(width: 300, height: 300)
                        .foregroundColor(Theme.defaultColor(scheme))
                } else if let image = image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 300)
                }
            }
            
            Button(action: { imagePickMode.toggle() }, label: {
                Text("Select image")
                    .font(.system(size: 15, weight: .semibold, design: .monospaced))
            })
            .sheet(isPresented: $imagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
            
            HStack {
                Text("Caption")
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(Theme.textColor(scheme))
                    .padding()
                Spacer()
            }
            HStack {
                Image(systemName: "pencil")
                    .font(.system(size: 20))
                    .foregroundColor(Theme.textColor(scheme))
                    .padding(.leading)
                
                if #available(iOS 16.0, *) {
                    TextField("Enter the caption...", text: $caption, axis: .vertical)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .padding()
                } else {
                    // Fallback on earlier versions
                    TextField("Enter the caption...", text: $caption)
                        .frame(height: 100)
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .padding()
                }
            }

                
        }.toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    mode.wrappedValue.dismiss()
                }, label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color.red)
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    mode.wrappedValue.dismiss()
                }, label: {
                    Text("Add")
                        .font(.system(size: 14, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                })
            }
        }
    }
}

extension EditPostView {
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
}
