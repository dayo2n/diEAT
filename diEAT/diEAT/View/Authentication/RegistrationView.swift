//
//  RegistrationView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import PopupView

struct RegistrationView: View {
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var pw: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var mode
    @Environment(\.colorScheme) var scheme
    
    @State private var registerInProgress: Bool = false
    
    // alert flag
    @State private var noBlank: Bool = false
    @State private var alreadyRegistered: Bool = false
    @State private var badFormatEmail: Bool = false
    @State private var badFormatPassword: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Text("diEAT")
                        .font(.system(size: 30, weight: .heavy, design: .monospaced))
                    Text("Sign up")
                        .font(.system(size: 13, weight: .light, design: .monospaced))
                    
                    Spacer()
                    VStack {
                        CustomTextField(text: $username, placeholder: Text("USERNAME"), imageName: "person")
                            .font(.system(size: 15, weight: .medium, design: .monospaced))
                            .padding(20)
                            .frame(height: 50)
                            .border(Theme.defaultColor(scheme), width: 0.7)
                            .padding([.leading, .trailing])
                            .padding([.top, .bottom], 10)
                        
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
                            if username.count == 0 || email.count == 0 || pw.count == 0 { noBlank.toggle() }
                            else {
                                registerInProgress = true
                                viewModel.register(username: username, email: email, pw: pw) { code in
                                switch code {
                                case 17007:
                                    alreadyRegistered.toggle()
                                case 17008:
                                    badFormatEmail.toggle()
                                case 17026:
                                    badFormatPassword.toggle()
                                default: // code == 0
                                    mode.wrappedValue.dismiss()
                                }
                                registerInProgress = false
                            }}
                            
                        }, label: {
                            Text("SIGN UP")
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .frame(width: UIScreen.main.bounds.size.width - 20 ,height: 50, alignment: .center)
                                .background(Theme.btnColor(scheme))
                                .cornerRadius(10)
                        })
                        
                        Button(action: { mode.wrappedValue.dismiss() }, label: {
                            HStack {
                                Text("Already have an account?")
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.defaultColor(scheme))
                                
                                Text("Sign in")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textColor(scheme))
                            }
                            .padding(.bottom, 16)
                        })
                    }.padding(.bottom, 30)
                    
                }
                if registerInProgress {
                    LinearGradient(colors: [.black.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(5)
                }
            }
            .background(Theme.bgColor(scheme))
            .popup(isPresented: $noBlank) {
                CustomPopUpView(alertText: "항목을 모두 작성하세요!", bgColor: .red)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $alreadyRegistered) {
                CustomPopUpView(alertText: "이미 가입되어 있는 이메일입니다.", bgColor: .red)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $badFormatEmail) {
                CustomPopUpView(alertText: "이메일 형식이 올바르지 않습니다.", bgColor: .red)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $badFormatPassword) {
                CustomPopUpView(alertText: "비밀번호를 6자리 이상 입력하세요.", bgColor: .red)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
        }
        .ignoresSafeArea()
    }
}
