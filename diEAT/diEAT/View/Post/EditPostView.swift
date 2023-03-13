//
//  EditPostView.swift
//  diEAT
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
    
    @State private var selectedIcon: String?
    @State private var popNoSelectedIconWarning: Bool = false
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel: EditPostViewModel = EditPostViewModel()
    @FocusState private var focused: Bool
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ZStack {
                    VStack {
                        ZStack {
                            if editMode {
                                KFImage(URL(string: post!.imageUrl))
                                    .resizable()
                                    .frame(width: geo.size.width - 20, height: geo.size.width - 20)
                                    .scaledToFit()
                                    .cornerRadius(8)
                            } else {
                                if image == nil {
                                    Rectangle()
                                        .frame(width: geo.size.width - 20, height: geo.size.width - 20)
                                        .foregroundColor(Theme.defaultColor(scheme))
                                        .cornerRadius(8)
                                } else if let image = image {
                                    image
                                        .resizable()
                                        .frame(width: geo.size.width - 20, height: geo.size.width - 20)
                                        .scaledToFit()
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.top, 100)
                        
                        Button(action: { imagePickMode.toggle() }, label: {
                            Text("Select image")
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .frame(height: 44)
                        })
                        .sheet(isPresented: $imagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
                        
                        HStack {
                            Text("# 식사")
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
                            Text("# 스티커")
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding([.leading, .top])
                            
                            Text("반드시 하나를 선택해 주세요")
                                .font(.system(size: 12, weight: .light, design: .monospaced))
                                .foregroundColor(Color.gray)
                                .padding([.leading, .top])
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button(action: {
                                selectedIcon = "exercise"
                            }, label: {
                                CustomIcon(iconName: "exercise")
                                    .shadow(color: .orange, radius: selectedIcon == "exercise" ? 5 : 0)
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
                                selectedIcon = "full"
                            }, label: {
                                CustomIcon(iconName: "full")
                                    .shadow(color: .orange, radius: selectedIcon == "full" ? 5 : 0)
                            })
                            Spacer()
                            Button(action: {
                                selectedIcon = "pig"
                            }, label: {
                                CustomIcon(iconName: "pig")
                                    .shadow(color: .orange, radius: selectedIcon == "pig" ? 5 : 0)
                            })
                            
                        }
                        .padding(.horizontal, 10)
                        
                        HStack {
                            Text("# 기록")
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
                            
                                TextField("스스로 피드백을 남기는 공간", text: $caption)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Theme.textColor(scheme))
                                    .padding(15)
                                    .border(Theme.defaultColor(scheme), width: 0.7)
                                    .padding()
                                    .focused($focused)
                                    .submitLabel(SubmitLabel.done)
                                    .onSubmit {
                                        focused.toggle()
                                    }
                        }.padding(.bottom, 50)
                        
                        HStack {
                            Rectangle()
                                .frame(height: 300)
                                .opacity(0.0)
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
                                viewModel.updatePost(id: "\(post!.id ?? "")", selectedDate: post?.timestamp.dateValue() ?? selectedDate, image: selectedImage!, caption: caption, mealtime: mealTime.rawValue, icon: selectedIcon) { _ in

                                    print("=== DEBUG: upload sucess on \(selectedDate)!")
                                    uploadPostProgress = false
                                    mode.wrappedValue.dismiss()
                                }
                            } else {
                                if selectedImage == nil {
                                    popNoImageWarning.toggle()
                                    print("=== DEBUG: no selected image")
                                } else {
                                    uploadPostProgress = true
                                    viewModel.uploadPost(selectedDate: UTC2KST(date: selectedDate), image: selectedImage!, caption: caption, mealtime: mealTime.rawValue, icon: selectedIcon) { _ in
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
                .popup(isPresented: $popNoImageWarning) {
                    CustomPopUpView(alertText: "업로드 실패!\n 식단 이미지를 첨부해 주세요 :(", bgColor: .red)
                } customize: { pop in
                    pop
                        .type(.floater())
                        .position(.top)
                        .dragToDismiss(true)
                        .closeOnTap(true)
                        .autohideIn(3)
                }
                .onAppear() {
                    getExistedLog()
                    if editMode { selectedIcon = post?.icon }
                }
            }
        }
        .ignoresSafeArea()
        .background(Theme.bgColor(scheme))
        .onDisappear() {
            focused = false
        }
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
