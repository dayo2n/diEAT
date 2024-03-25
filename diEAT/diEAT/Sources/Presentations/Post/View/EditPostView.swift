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
    
    enum Icon: String {
        case exercise
        case elephant
        case full
        case pig
    }
    
    var post: Post?
    @State var isEditMode: Bool
    @Binding var selectedDate: Date
    @Binding var isShownThisView: Bool
    
    @State private var didPressedUploadButton = false
    @State private var isUploadPostInProgress = false
    @State private var isImagePickMode = false
    @State private var selectedImage: UIImage?
    @State private var image: Image?
    @State private var popNoImageWarning = false
    
    @State private var caption = ""
    @State private var mealTime = MealTime.Breakfast
    
    @State private var selectedIcon: String?
    @State private var popNoSelectedIconWarning = false
    
    @Environment(\.colorScheme) var scheme
    @Environment(\.presentationMode) var mode
    @ObservedObject var viewModel = EditPostViewModel()
    @FocusState private var focused: Bool
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                ZStack {
                    VStack {
                        // toolbar
                        HStack {
                            // cancel
                            Button {
                                self.isShownThisView.toggle()
                            } label: {
                                Text(String.cancel)
                                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                                    .foregroundColor(Color.red)
                                    .opacity(didPressedUploadButton ? 0.2 : 1.0)
                            }
                            .disabled(didPressedUploadButton)
                            
                            Spacer()
                            
                            // add || edit
                            Button(action: {
                                didPressedUploadButton = true
                                
                                if isEditMode {
                                    isUploadPostInProgress = true
                                    viewModel.updatePost(
                                        id: "\(post!.id ?? "")",
                                        selectedDate: post?.timestamp.dateValue() ?? selectedDate,
                                        image: selectedImage!,
                                        caption: caption,
                                        mealtime: mealTime.rawValue,
                                        icon: selectedIcon
                                    ) { _ in
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
                                        viewModel.uploadPost(
                                            selectedDate: UTC2KST(date: selectedDate),
                                            image: selectedImage!,
                                            caption: caption,
                                            mealtime: mealTime.rawValue,
                                            icon: selectedIcon
                                        ) { _ in
                                            print("=== DEBUG: upload sucess on \(selectedDate)!")
                                            isUploadPostInProgress = false
                                            mode.wrappedValue.dismiss()
                                        }
                                    }
                                }
                            }, label: {
                                Text(isEditMode ? String.edit : String.add)
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
                                    .frame(
                                        width: geo.size.width - 20,
                                        height: geo.size.width - 20
                                    )
                                    .cornerRadius(8)
                            } else {
                                if image == nil {
                                    Rectangle()
                                        .frame(
                                            width: geo.size.width - 20,
                                            height: geo.size.width - 20
                                        )
                                        .foregroundColor(Theme.defaultColor(scheme))
                                        .cornerRadius(8)
                                } else if let image = image {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .frame(
                                            width: geo.size.width - 20,
                                            height: geo.size.width - 20
                                        )
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        Button {
                            isImagePickMode.toggle()
                        } label: {
                            Text(String.selectImage)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .frame(height: 44)
                        }
                        .sheet(
                            isPresented: $isImagePickMode,
                            onDismiss: loadImage,
                            content: { ImagePicker(image: $selectedImage) }
                        )
                        
                        HStack {
                            Text(String.mealHeader)
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
                            Text(String.stickerHeader)
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding([.leading, .top])
                            Spacer()
                        }
                        
                        HStack {
                            Button {
                                selectedIcon = Icon.exercise.rawValue
                            } label: {
                                CustomIcon(iconName: Icon.exercise.rawValue)
                                    .shadow(
                                        color: .orange,
                                        radius: selectedIcon == Icon.exercise.rawValue ? 5 : 0
                                    )
                            }
                            Spacer()
                            Button {
                                selectedIcon = Icon.elephant.rawValue
                            } label: {
                                CustomIcon(iconName: Icon.elephant.rawValue)
                                    .shadow(
                                        color: .orange,
                                        radius: selectedIcon == Icon.elephant.rawValue ? 5 : 0
                                    )
                            }
                            Spacer()
                            Button {
                                selectedIcon = Icon.full.rawValue
                            } label: {
                                CustomIcon(iconName: Icon.full.rawValue)
                                    .shadow(
                                        color: .orange,
                                        radius: selectedIcon == Icon.full.rawValue ? 5 : 0
                                    )
                            }
                            Spacer()
                            Button {
                                selectedIcon = Icon.pig.rawValue
                            } label: {
                                CustomIcon(iconName: Icon.pig.rawValue)
                                    .shadow(
                                        color: .orange,
                                        radius: selectedIcon == Icon.pig.rawValue ? 5 : 0
                                    )
                            }
                        }
                        .padding(.horizontal, 10)
                        
                        HStack {
                            Text(String.recordHeader)
                                .font(.system(size: 16, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding([.horizontal, .top])
                            Spacer()
                        }
                        HStack {
                            Image(systemName: .pencil)
                                .font(.system(size: 20))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(.leading)
                            
                            TextField(
                                String.captionPlaceholder,
                                text: $caption
                            )
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
                        }
                        .padding(.bottom, 50)
                        
                        HStack {
                            Rectangle()
                                .frame(height: 300)
                                .opacity(0.0)
                        }
                    }
                    if isUploadPostInProgress {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(5)
                    }
                }
                .popup(isPresented: $popNoImageWarning) {
                    CustomPopUpView(alertText: .alertFailedToUpload, bgColor: .red)
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
            if let url = URL(string: post!.imageUrl) {
                KingfisherManager.shared.retrieveImage(
                    with: url
                ) { result in
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
    }
}
