//
//  EditProfileView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/07.
//

import SwiftUI
import Kingfisher

struct EditProfileView: View {
    
    let user: User
    @Environment(\.colorScheme) var scheme
    @State var newUsername = ""
    @Environment(\.dismiss) private var dismiss
    
    @State var isImagePickMode = false
    @State var selectedImage: UIImage?
    @State var progressGuage = 1.0
    
    // sheet
    @State private var resetEmailSended = false
    @State private var sureToDeleteUser = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                        // AuthViewModel에서 유저 네임 변경 함수 구현
                        if newUsername.isEmpty { newUsername = user.username }
                        AuthViewModel.shared.editUsername(newUsername: newUsername)
                    } label: {
                        Text(String.complete)
                    }
                    .padding(10)
                }
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
                        Image(String.defaultProfileImage)
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
                    
                    Button {
                        isImagePickMode.toggle()
                    } label: {
                        VStack {
                            Spacer()
                            Text(String.editText)
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(.bottom, 8)
                        }.frame(width: 120, height: 120)
                    }
                    .sheet(
                        isPresented: $isImagePickMode,
                        onDismiss: loadImage) {
                            ImagePicker(image: $selectedImage)
                        }
                    
                    if progressGuage == 0.0 {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding(20)
                    }
                }
                HStack {
                    Image(systemName: String.envelope)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text(user.email)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                    
                    Spacer()
                }
                .padding(20)
                .frame(height: 50)
                .border(Theme.defaultColor(scheme), width: 0.7)
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                CustomTextField(
                    text: $newUsername,
                    placeholder: Text(user.username),
                    imageName: scheme == .dark ? String.personFill : String.person
                )
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .padding(20)
                .frame(height: 50)
                .border(Theme.defaultColor(scheme), width: 0.7)
                .padding(.horizontal)
                
                Divider()
                    .padding(.all)
                
                Button {
                    AuthViewModel.shared.resetPassword(email: user.email)
                    resetEmailSended.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: scheme == .dark ? String.keyFill : String.key)
                            .frame(width: 20, height: 20)
                        Text(String.changePassword)
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                        Spacer()
                    }
                    .foregroundColor(Theme.bgColor(scheme))
                    .padding(20)
                    .frame(height: 50)
                    .background(Theme.defaultColor(scheme))
                    .padding(.horizontal)
                }
                .alert(
                    String.successToSend,
                    isPresented: $resetEmailSended
                ) {
                    Button(
                        String.optionCheck,
                        role: .cancel
                    ) {
                        resetEmailSended.toggle()
                        AuthViewModel.shared.logout()
                    }
                } message: {
                    Text(String.checkEmailBoxMessage)
                }
                
                Spacer()
                
                Button {
                    sureToDeleteUser.toggle()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: String.personCropCircleFillBadgeXmark)
                            .foregroundColor(Theme.textColor(scheme))
                        Text(String.withdrawal)
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .opacity(0.8)
                            .padding(.leading, 10)
                    }
                    .padding(.trailing, 30)
                    .padding(.vertical)
                }
                .alert(
                    String.withdrawal,
                    isPresented: $sureToDeleteUser
                ) {
                    Button(
                        String.optionCancel,
                        role: .cancel
                    ) {
                        sureToDeleteUser = false
                    }
                    Button(
                        String.optionWithdrawal,
                        role: .destructive
                    ) {
                        AuthViewModel.shared.deleteUser()
                    }
                } message: {
                    Text(String.withdrawalCautionMessage)
                }
            }
            .padding(.top)
            .background(Theme.bgColor(scheme))
        }
    }
    
    func loadImage() {
        guard let selectedImage = selectedImage else { return }
        self.progressGuage = 0.0
        AuthViewModel.shared.uploadProfileImage(newProfileImage: selectedImage) {
            self.progressGuage = 1.0
        }
    }
}
