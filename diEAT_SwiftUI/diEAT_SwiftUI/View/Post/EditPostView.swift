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
    
    var post: Post?
    @State var editMode: Bool // true: 수정모드, false: 새 글 작성 모드
    @Binding var selectedDate: Date
    
    @State private var uploadPostProgress: Bool = false
    @State private var imagePickMode: Bool = false
    @State private var selectedImage: UIImage?
    @State private var image: Image?
    @State private var popNoImageWarning: Bool = false
    
    @State private var caption: String = ""
    @State private var mealTime: MealTime = .Breakfast
    
    @State private var selectedIcon: String = ""
    @State private var popNoSelectedIconWarning: Bool = false
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel: EditPostViewModel = EditPostViewModel()
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    ZStack {
                        if editMode {
                            KFImage(URL(string: post!.imageUrl))
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                                .scaledToFit()
                        } else {
                            if image == nil {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                                    .foregroundColor(Theme.defaultColor(scheme))
                            } else if let image = image {
                                image
                                    .resizable()
                                    .frame(width: UIScreen.main.bounds.width - 20, height: UIScreen.main.bounds.width - 20)
                                    .scaledToFit()
                            }
                        }
                    }
                    .padding(.top, editMode ? 100 : 60)
                    
                    Button(action: { imagePickMode.toggle() }, label: {
                        Text("Select image")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .padding(.bottom)
                    })
                    .sheet(isPresented: $imagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
                    
                    HStack {
                        Text("# 식사 시간대")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .padding([.horizontal, .top])
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
                        Text("# 오늘의 스티커")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .padding([.horizontal, .top])
                        Spacer()
                    }
                    
                    HStack {
                        Button(action: {
                            selectedIcon = scheme == .dark ? "exercise_dark" : "exercise_light"
                        }, label: {
                            CustomIcon(iconName: scheme == .dark ? "exercise_dark" : "exercise_light")
                                .shadow(color: .orange, radius: selectedIcon == (scheme == .dark ? "exercise_dark" : "exercise_light") ? 5 : 0)
                        })
                        Spacer()
                        Button(action: {
                            selectedIcon = "elephant"
                        }, label: {
                            CustomIcon(iconName: "elephant")
                                .shadow(color: .orange, radius: selectedIcon == "elephant" ? 5 : 0)
                        })
                        Spacer()
                        Button(action: {
                            selectedIcon = scheme == .dark ? "full_dark" : "full_light"
                        }, label: {
                            CustomIcon(iconName: scheme == .dark ? "full_dark" : "full_light")
                                .shadow(color: .orange, radius: selectedIcon == (scheme == .dark ? "full_dark" : "full_light") ? 5 : 0)
                        })
                        Spacer()
                        Button(action: {
                            selectedIcon = "pig"
                        }, label: {
                            CustomIcon(iconName: "pig")
                                .shadow(color: .orange, radius: selectedIcon == "pig" ? 5 : 0)
                        })
                        
                    }
                    
                    HStack {
                        Text("# 짧은 기록")
                            .font(.system(size: 16, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .padding([.horizontal, .top])
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
                                .padding([.horizontal, .bottom])
                        } else {
                            // Fallback on earlier versions
                            TextField("Enter the caption...(0 to 30)", text: $caption)
                                .frame(height: 30)
                                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding([.horizontal, .bottom])
                        }
                    }.padding(.bottom, 50)
                }
                if uploadPostProgress {
                    LinearGradient(colors: [.black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(5)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { mode.wrappedValue.dismiss() }, label: {
                        Text(editMode ? "" : "Cancel")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color.red)
                    })
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if editMode {
                            uploadPostProgress = true
                            viewModel.updatePost(id: "\(post!.id ?? "")", selectedDate: post?.timestamp.dateValue() ?? selectedDate, image: selectedImage!, caption: caption, mealtime: mealTime.rawValue) { _ in

                                print("=== DEBUG: upload sucess on \(selectedDate)!")
                                uploadPostProgress = false
                                mode.wrappedValue.dismiss()
                            }
                        } else {
                            if selectedImage == nil {
                                popNoImageWarning.toggle()
                                print("=== DEBUG: no selected image")
                            } else if selectedIcon.count == 0 {
                                popNoSelectedIconWarning.toggle()
                                print("=== DEBUG: no selected icon")
                            } else {
                                uploadPostProgress = true
                                viewModel.uploadPost(selectedDate: UTC2KST(date: selectedDate), image: selectedImage!, caption: caption, mealtime: mealTime.rawValue) { _ in
                                    print("=== DEBUG: upload sucess on \(selectedDate)!")
                                    uploadPostProgress = false
                                    mode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }, label: {
                        Text(editMode ? "Edit" : "Add")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                    })
                }
            }
            .popup(isPresented: $popNoImageWarning, type: .floater(), position: .top, autohideIn: 3) {
                Text("업로드 실패!\n 식단 이미지를 첨부해 주세요 :(")
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .padding([.leading, .trailing], 20)
                    .padding([.bottom, .top], 10)
                    .foregroundColor(Theme.textColor(scheme))
                    .background(.red)
                    .cornerRadius(30.0)
                    .multilineTextAlignment(.center)
            }
            .popup(isPresented: $popNoSelectedIconWarning, type: .floater(), position: .top, autohideIn: 3) {
                Text("업로드 실패!\n 오늘의 스티커를 선택해 주세요 :(")
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .padding([.leading, .trailing], 20)
                    .padding([.bottom, .top], 10)
                    .foregroundColor(Theme.textColor(scheme))
                    .background(.red)
                    .cornerRadius(30.0)
                    .multilineTextAlignment(.center)
            }
            .onAppear() {
                getExistedLog()
            }
        }
        .ignoresSafeArea()
        .background(Theme.bgColor(scheme))
    }
}

extension EditPostView {
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        image = Image(uiImage: selectedImage)
    }
    
    func getExistedLog() {
        if editMode {
            mealTime = MealTime(rawValue: post!.mealtime)!
            caption = post!.caption
            KingfisherManager.shared.retrieveImage(with: ImageResource(downloadURL: URL(string: post!.imageUrl)!)) { result in
                switch result {
                case .success(let value):
                    selectedImage = value.image as UIImage
                    loadImage()
                case .failure(let error):
                    print("=== DEBUG: \(error)")
                }
            }
        }
    }
    
    func selectedIconEvent(iconName: String) {
        selectedIcon = iconName
        
    }
}
