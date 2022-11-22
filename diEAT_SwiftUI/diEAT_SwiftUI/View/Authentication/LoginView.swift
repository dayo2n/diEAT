//
//  LoginView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI
import PopupView

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var pw: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var scheme
    
    // sheet
    @State private var resetPassword: Bool = false
    @State private var resetTargetEmail: String = ""
    
    // alert
    @State private var noBlank: Bool = false
    @State private var alertInvalidPassword: Bool = false
    @State private var resetEmailSended: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("diEAT")
                    .font(.system(size: 30, weight: .heavy, design: .monospaced))
                Text("Sign in")
                    .font(.system(size: 13, weight: .light, design: .monospaced))
                
                Spacer()
                VStack {
                    CustomTextField(text: $email, placeholder: Text("EMAIL"), imageName: "envelope")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(scheme), width: 0.7)
                        .padding([.leading, .trailing])
                    
                    CustomSecureField(password: $pw, placeholder: Text("PASSWORD"))
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(scheme), width: 0.7)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                    
                    Button(action: {
                        if email.count == 0 || pw.count == 0 {
                            noBlank.toggle()
                        } else {
                            viewModel.login(email: email, pw: pw) { bool in
                                if !bool { alertInvalidPassword.toggle() }
                            }
                        }}, label: {
                        Text("LOGIN")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .frame(width: UIScreen.main.bounds.size.width - 20 ,height: 50, alignment: .center)
                            .background(Theme.btnColor(scheme))
                            .cornerRadius(10)
                    })
                    
                    NavigationLink(destination: RegistrationView().navigationBarHidden(true), label: {
                        HStack {
                            Text("계정이 없다면")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.defaultColor(scheme))
                            
                            Text("회원가입")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textColor(scheme))
                        }
                        .padding(.vertical, 10)
                    })
                    
                    Button(action: { resetPassword.toggle() }, label: {
                        HStack {
                            Text("비밀번호를 잊어버렸다면")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.defaultColor(scheme))
                            
                            Text("비밀번호 재설정")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textColor(scheme))
                        }
                        .padding(.bottom, 16)
                    })
                }.padding(.bottom, 30)
            }
        }
        .popup(isPresented: $noBlank, type: .floater(), position: .top, autohideIn: 3) {
            CustomPopUpView(alertText: "로그인 정보를 모두 입력하세요!", bgColor: .red)
        }
        .popup(isPresented: $alertInvalidPassword, type: .floater(), position: .top, autohideIn: 3) {
            CustomPopUpView(alertText: "잘못된 비밀번호입니다.", bgColor: .red)
        }
        .sheet(isPresented: $resetPassword, content: {
            if #available(iOS 16.0, *) {
                VStack {
                    HStack {
                        Text("비밀번호를 재설정할 이메일 입력")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(Theme.textColor(scheme))
                            .padding(20)
                        Spacer()
                    }
                    CustomTextField(text: $resetTargetEmail, placeholder: Text("EMAIL"), imageName: "envelope")
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(scheme), width: 0.7)
                        .padding([.leading, .trailing])
                    
                    Button(action: {
                        viewModel.resetPassword(email: resetTargetEmail)
                        resetEmailSended.toggle()
                    }, label: {
                        Text("재설정 메일 전송")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .frame(width: UIScreen.main.bounds.size.width - 20 ,height: 50, alignment: .center)
                            .background(Theme.btnColor(scheme))
                            .cornerRadius(10)
                            .padding(.top)
                    })
                    .alert("전송 성공", isPresented: $resetEmailSended) {
                        Button("확인", role: .cancel, action: {
                            resetEmailSended.toggle()
                            resetPassword = false
                            resetTargetEmail = ""
                        })
                    } message: {
                        Text("수신한 이메일을 통해 비밀번호를 재설정하세요. 이메일이 도착하지 않으면 스팸메일함을 확인하세요.")
                    }
                }.presentationDetents([.height(UIScreen.main.bounds.height / 3)])
            } else {
                // Fallback on earlier versions
            }
        })
        .ignoresSafeArea()
        .background()
        .background(Theme.bgColor(scheme))
    }
}
