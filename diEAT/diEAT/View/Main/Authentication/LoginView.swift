//
//  LoginView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI
import PopupView

struct LoginView: View {
    
    @State private var email = ""
    @State private var pw = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var scheme
    
    @State private var isLoginInProgress = false
    
    // sheet
    @State private var resetPassword = false
    @State private var resetTargetEmail = ""
    
    // alert
    @State private var hasNoBlank = false
    @State private var alertInvalidInput = false
    @State private var resetEmailSended = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.opacity(0.7)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(String.app)
                        .font(.system(size: 30, weight: .heavy, design: .monospaced))
                    Text(String.signIn)
                        .font(.system(size: 13, weight: .light, design: .monospaced))
                    
                    Spacer()
                    VStack {
                        CustomTextField(
                            text: $email,
                            placeholder: Text(String.email),
                            imageName: String.envelope
                        )
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(scheme), width: 0.7)
                        .padding([.leading, .trailing])
                        
                        CustomSecureField(
                            password: $pw,
                            placeholder: Text(String.password)
                        )
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(scheme), width: 0.7)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                        
                        Button {
                            if email.count == 0 || pw.count == 0 {
                                hasNoBlank.toggle()
                            } else {
                                isLoginInProgress = true
                                viewModel.login(email: email, pw: pw) { bool in
                                    if !bool {
                                        alertInvalidInput.toggle()
                                    }
                                    isLoginInProgress = false
                                }
                            }
                        } label: {
                            Text(String.login)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(scheme))
                                .frame(
                                    width: UIScreen.main.bounds.size.width - 20,
                                    height: 50, alignment: .center
                                )
                                .background(Theme.btnColor(scheme))
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(
                            destination: RegistrationView()
                                .navigationBarHidden(true)
                                .navigationViewStyle(StackNavigationViewStyle())
                        ) {
                            HStack {
                                Text(String.ifHasNoAuth)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.defaultColor(scheme))
                                
                                Text(String.registration)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textColor(scheme))
                            }
                            .padding(.vertical, 10)
                        }
                        
                        Button {
                            resetPassword.toggle()
                        } label: {
                            HStack {
                                Text(String.ifForgotPassword)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.defaultColor(scheme))
                                
                                Text(String.changePassword)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textColor(scheme))
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
            }
            .background(Theme.bgColor(scheme))
            
            if isLoginInProgress {
                Color.black.opacity(0.5).ignoresSafeArea()
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(5)
            }
        }
        .popup(isPresented: $hasNoBlank) {
            CustomPopUpView(alertText: String.alertPutAllAuthInformation, bgColor: .red)
        } customize: { pop in
            pop
                .type(.floater())
                .position(.top)
                .closeOnTap(true)
                .dragToDismiss(true)
                .autohideIn(2)
                .isOpaque(true)
        }
        .popup(isPresented: $alertInvalidInput) {
            CustomPopUpView(alertText: String.alertWrongInput, bgColor: .red)
        } customize: { pop in
            pop
                .type(.floater())
                .position(.top)
                .closeOnTap(true)
                .dragToDismiss(true)
                .autohideIn(2)
                .isOpaque(true)
        }
        .sheet(isPresented: $resetPassword) {
            VStack {
                HStack {
                    Text(String.inputEmailToResetPassword)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.textColor(scheme))
                        .padding(20)
                    Spacer()
                }
                CustomTextField(
                    text: $resetTargetEmail,
                    placeholder: Text(String.email),
                    imageName: String.envelope
                )
                .font(.system(size: 15, weight: .medium, design: .monospaced))
                .padding(20)
                .frame(height: 50)
                .border(Theme.defaultColor(scheme), width: 0.7)
                .padding([.leading, .trailing])
                
                Button {
                    viewModel.resetPassword(email: resetTargetEmail)
                    resetEmailSended.toggle()
                } label: {
                    Text(String.sendResetEmail)
                        .font(.system(size: 15, weight: .semibold, design: .monospaced))
                        .foregroundColor(Theme.textColor(scheme))
                        .frame(width: UIScreen.main.bounds.size.width - 20 ,height: 50, alignment: .center)
                        .background(Theme.btnColor(scheme))
                        .cornerRadius(10)
                        .padding(.top)
                }
                .alert(String.successToSend, isPresented: $resetEmailSended) {
                    Button(
                        String.optionCheck,
                        role: .cancel
                    ) {
                        resetEmailSended.toggle()
                        resetPassword = false
                        resetTargetEmail = ""
                    }
                } message: {
                    Text(String.checkEmailBoxMessage)
                }
            }
            .presentationDetents([.height(UIScreen.main.bounds.height / 3)])
        }
        .ignoresSafeArea()
    }
}
