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
    @State var newUsername: String = ""
    @Environment(\.dismiss) private var dismiss
    
    @State var isImagePickMode: Bool = false
    @State var selectedImage: UIImage?
    @State var progressGuage: Double = 1.0
    
    // sheet
    @State private var resetEmailSended: Bool = false
    @State private var sureToDeleteUser: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()

                    Button(action: {
                        dismiss()
                        // AuthViewModel에서 유저 네임 변경 함수 구현
                        if newUsername.isEmpty { newUsername = user.username }
                        AuthViewModel.shared.editUsername(newUsername: newUsername)
                    }, label: {
                        Text("완료")
                    }).padding(10)
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
                    
                    Button(action: { isImagePickMode.toggle() }, label: {
                        VStack {
                            Spacer()
                            
                            Text("편집")
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .padding(.bottom, 8)
                        }.frame(width: 120, height: 120)
                    })
                    .sheet(isPresented: $isImagePickMode, onDismiss: loadImage, content: { ImagePicker(image: $selectedImage) })
                    
                    if progressGuage == 0.0 {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(2)
                            .padding(20)
                    }
                }
                
                HStack {
                    Image(systemName: "envelope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("\(user.email)")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                    
                    Spacer()
                }
                .padding(20)
                .frame(height: 50)
                .border(Theme.defaultColor(scheme), width: 0.7)
                .padding(.horizontal)
                .padding(.vertical, 10)
                
                CustomTextField(text: $newUsername, placeholder: Text("\(user.username) "), imageName: scheme == .dark ? "person.fill" : "person")
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .padding(20)
                    .frame(height: 50)
                    .border(Theme.defaultColor(scheme), width: 0.7)
                    .padding(.horizontal)
                
                Divider()
                    .padding(.all)
                
                Button(action: {
                    AuthViewModel.shared.resetPassword(email: user.email)
                    resetEmailSended.toggle()
                }, label: {
                    HStack {
                        Spacer()
                        
                        Image(systemName: scheme == .dark ? "key.fill" : "key")
                            .frame(width: 20, height: 20)
                        
                        Text("비밀번호 재설정")
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                        
                        Spacer()
                    }
                    .foregroundColor(Theme.bgColor(scheme))
                    .padding(20)
                    .frame(height: 50)
                    .background(Theme.defaultColor(scheme))
                    .padding(.horizontal)
                })
                .alert("전송 성공", isPresented: $resetEmailSended) {
                    Button("확인", role: .cancel, action: {
                        resetEmailSended.toggle()
                        AuthViewModel.shared.logout()
                    })
                } message: {
                    Text("수신한 이메일을 통해 비밀번호를 재설정 후 다시 로그인하세요. 이메일이 도착하지 않으면 스팸메일함을 확인하세요.")
                }
                
                Spacer()
                
                Button(action: {
                    sureToDeleteUser.toggle()
                }, label: {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "person.crop.circle.fill.badge.xmark")
                            .foregroundColor(Theme.textColor(scheme))
                        
                        Text("회원 탈퇴")
                            .font(.system(size: 16, weight: .medium, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .opacity(0.8)
                            .padding(.leading, 10)
                    }
                    .padding(.trailing, 30)
                    .padding(.vertical)
                })
                .alert("회원 탈퇴", isPresented: $sureToDeleteUser) {
                    Button("취소", role: .cancel, action: {
                        sureToDeleteUser = false
                    })
                    Button("탈퇴", role: .destructive, action: {
                        AuthViewModel.shared.deleteUser()
                    })
                } message: {
                    Text("탈퇴 후 데이터를 복원할 수 없습니다.")
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
