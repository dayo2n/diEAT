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
    @State var isEditMode: Bool
    @Binding var selectedDate: Date
    @Binding var isShownThisView: Bool
    
    @State private var didPressedUploadButton: Bool = false
    @State private var isUploadPostInProgress: Bool = false
    @State private var isImagePickMode: Bool = false
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
                        // toolbar
                        HStack {
                            // cancel
                            Button(action: {
                                self.isShownThisView.toggle()
                            }, label: {
                                Text("Cancel")
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Color.red)
                                    .opacity(didPressedUploadButton ? 0.2 : 1.0)
                            })
                            .disabled(didPressedUploadButton)
                            
                            Spacer()
                            
                            // add || edit
                            Button(action: {
                                didPressedUploadButton = true
                                
                                if isEditMode {
                                    isUploadPostInProgress = true
                                    viewModel.updatePost(id: "\(post!.id ?? "")", selectedDate: post?.timestamp.dateValue() ?? selectedDate, image: selectedImage!, caption: caption, mealtime: mealTime.rawValue, icon: selectedIcon) { _ in

                                        print("=== DEBUG: upload sucess on \(selectedDate)!")
                                        isUploadPostInProgress = false
                                        mode.wrappedValue.dismiss()
                                    }
                                } else {
                                    if selectedImage == nil {
                                        popNoImageWarning.toggle()
                                        print("=== DEBUG: no selected image")
                                    } else {
                                        isUploadPostInProgress = true
                                        viewModel.uploadPost(selectedDate: UTC2KST(date: selectedDate), image: selectedImage!, caption: caption, mealtime: mealTime.rawValue, icon: selectedIcon) { _ in
                                            print("=== DEBUG: upload sucess on \(selectedDate)!")
                                            isUploadPostInProgress = false
                                            mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            }, label: {
                                Text(isEditMode ? "Edit" : "Add")
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Theme.textColor(scheme))
                                    .opacity(didPressedUploadButton ? 0.2 : 1.0)
                            })
                            .disabled(didPressedUploadButton)
                        }
                        .padding(.top, 80)
                        .padding(.horizontal, 20)
                        
                        // editor
                        ZStack {
                            if isEditMode {
                                KFImage(URL(string: post!.imageUrl))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geo.size.width - 20, height: geo.size.width - 20)
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
                                    .scaledToFit()
                                    .frame(width: geo.size.width - 20, height: geo.size.width - 20)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        Button(action: { isImagePickMode.toggle() }, label: {
                            Text("Select image")
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .frame(height: 44)
                        })
                        .sheet(isPresented: $isImagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
                        
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
                    if isUploadPostInProgress {
                        LinearGradient(colors: [.black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(5)
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
                    if isEditMode { selectedIcon = post?.icon }
                }
            }
            .ignoresSafeArea()
            .navigationBarBackButtonHidden(true)
        }
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
        if isEditMode {
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
