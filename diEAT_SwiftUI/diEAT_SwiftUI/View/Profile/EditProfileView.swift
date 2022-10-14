//
//  EditProfileView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/07.
//

import SwiftUI
import Kingfisher

struct EditProfileView: View {
    let user: User
    @Environment(\.colorScheme) var scheme
    @State var newUsername: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @State var imagePickMode: Bool = false
    @State var selectedImage: UIImage?
    @State var progressGuage: Double = 1.0
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Circle()
                        .frame(width: 122, height: 122)
                        .foregroundColor(Theme.bgColor(scheme))
                    
                    if let profileImgUrl = user.profileImageUrl {
                            KFImage(URL(string: profileImgUrl))
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                    } else {
                        Image("defaultProfileImg")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .foregroundColor(Theme.defaultColor(scheme))
                    }
                    Circle()
                        .trim(from: 0.08, to: 0.42)
                        .frame(width: 120, height: 120)
                        .foregroundColor(Theme.bgColor(scheme))
                        .opacity(0.7)
                    
                    Button(action: { imagePickMode.toggle() }, label: {
                        VStack {
                            Spacer()
                            
                            Text("편집")
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(.bottom, 8)
                        }.frame(width: 120, height: 120)
                    })
                    .sheet(isPresented: $imagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
                    
                    if progressGuage == 0.0 {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding(20)
                    }
                }
                
                CustomTextField(text: $newUsername, placeholder: Text("\(user.username) "), imageName: scheme == .dark ? "person.fill" : "person")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .padding(20)
                    .frame(height: 50)
                    .border(Theme.defaultColor(scheme), width: 0.7)
                    .padding([.leading, .trailing])
                
                Spacer()
            }.background(Theme.bgColor(scheme))
        }.toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    // AuthViewModel에서 유저 네임 변경 함수 구현
                    AuthViewModel.shared.editUsername(newUsername: newUsername)
                    dismiss()
                }, label: {
                    Text("변경")
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                })
            }
        }
    }
    
    func loadImage() {
        print("=== DEBUG: \(progressGuage)")
        guard let selectedImage = selectedImage else { return }
        self.progressGuage = 0.0
        print("=== DEBUG: \(progressGuage)")
        AuthViewModel.shared.uploadProfileImage(newProfileImage: selectedImage) {
            self.progressGuage = 1.0
            print("=== DEBUG: \(progressGuage)")
        }
    }
}
