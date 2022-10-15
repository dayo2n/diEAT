//
//  EditPostView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/13.
//

import SwiftUI
import Kingfisher
import PopupView

enum MealTime: String, CaseIterable, Identifiable {
    case Breakfast, Lunch, Dinner, etc
    var id: Self { self } // Identifiable 프로토콜을 받으면 ForEach문을 사용 가능
}

struct EditPostView: View {
    
    @State var editMode: Bool // true: 수정모드, false: 새 글 작성 모드
    @Binding var editPostMode: Bool
    @Binding var selectedDate: Date
    
    @State private var uploadPostProgress: Bool = false
    @State private var imagePickMode: Bool = false
    @State private var selectedImage: UIImage?
    @State private var image: Image?
    @State private var popNoImageWarning: Bool = false
    
    @State private var caption: String = ""
    @State private var mealTime: MealTime = .Breakfast
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel: EditPostViewModel = EditPostViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                ZStack {
                    if image == nil {
                        Rectangle()
                            .frame(width: 300, height: 300)
                            .foregroundColor(Theme.defaultColor(scheme))
                    } else if let image = image {
                        image
                            .resizable()
                            .frame(width: 300, height: 300)
                            .scaledToFit()
                    }
                }
                .padding(.top)
                
                Button(action: { imagePickMode.toggle() }, label: {
                    Text("Select image")
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .padding(.bottom)
                })
                .sheet(isPresented: $imagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
                
                HStack {
                    Text("Meal Time")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .padding()
                    Spacer()
                }
                
                Picker("MealTime", selection: $mealTime) {
                    ForEach(MealTime.allCases) { time in
                        Text(time.rawValue.capitalized)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                    }
                }
                .pickerStyle(.segmented)
                .padding([.leading, .trailing, .bottom])
                
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
                        TextField("Enter the caption...(0 to 30)", text: $caption)
                            .frame(height: 30)
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .padding()
                    }
                }
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { mode.wrappedValue.dismiss() }, label: {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.red)
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if selectedImage == nil {
                            popNoImageWarning.toggle()
                            print("=== DEBUG: no selected image")
                        } else {
                            uploadPostProgress = true
                            viewModel.uploadPost(selectedDate: selectedDate, image: selectedImage!, caption: caption, mealtime: mealTime.rawValue) { _ in
                                print("=== DEBUG: upload sucess on \(selectedDate)!")
                                uploadPostProgress = false
                                mode.wrappedValue.dismiss()
                            }
                        }
                    }, label: {
                        Text("Add")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                    })
                }
            }
            if uploadPostProgress {
                LinearGradient(colors: [.black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(5)
            }
        }
        .popup(isPresented: $popNoImageWarning, type: .floater(), position: .bottom, autohideIn: 3) {
            Text("업로드 실패!\n 식단 이미지를 첨부해 주세요 :(")
                .font(.system(size: 17, weight: .medium, design: .monospaced))
                .padding([.leading, .trailing], 20)
                .padding([.bottom, .top], 10)
                .foregroundColor(Theme.textColor(scheme))
                .background(.red)
                .cornerRadius(30.0)
                .multilineTextAlignment(.center)
        }
    }
}

extension EditPostView {
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
}