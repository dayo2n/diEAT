//
//  RegistrationView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import PopupView

struct RegistrationView: View {
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isRegisterInProgress = false
    
    // alert flag
    @State private var noBlank = false
    @State private var alreadyRegistered = false
    @State private var badFormatEmail = false
    @State private var badFormatPassword = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image(String.backgroundImageDark)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text(String.app)
                        .font(.system(size: 30, weight: .heavy, design: .monospaced))
                    Text(String.signUp)
                        .font(.system(size: 13, weight: .light, design: .monospaced))
                    
                    Spacer()
                    VStack {
                        CustomTextField(
                            text: $username,
                            placeholder: Text(String.username),
                            imageName: String.person)
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(colorScheme), width: 0.7)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                        
                        CustomTextField(
                            text: $email,
                            placeholder: Text(String.email),
                            imageName: String.envelope
                        )
                        .font(.system(size: 15, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(colorScheme), width: 0.7)
                        .padding([.leading, .trailing])
                        
                        CustomSecureField(
                            password: $password,
                            placeholder: Text(String.password)
                        )
                        .padding(20)
                        .frame(height: 50)
                        .border(Theme.defaultColor(colorScheme), width: 0.7)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 10)
                        
                        Button {
                            if username.count == 0
                                || email.count == 0
                                || password.count == 0 {
                                noBlank.toggle()
                            } else {
                                isRegisterInProgress = true
                                viewModel.register(
                                    username: username,
                                    email: email,
                                    password: password
                                ) { code in
                                    switch ErrorCode(rawValue: code) {
                                    case .alreadyRegistered:
                                        alreadyRegistered.toggle()
                                    case .invalidFormatEmail:
                                        badFormatEmail.toggle()
                                    case .invalidFormatPassword:
                                        badFormatPassword.toggle()
                                    default:
                                        dismiss()
                                    }
                                    isRegisterInProgress = false
                                }
                            }
                        } label: {
                            Text(String.signUp)
                                .font(.system(size: 15, weight: .semibold, design: .monospaced))
                                .foregroundColor(Theme.textColor(colorScheme))
                                .frame(
                                    width: UIScreen.main.bounds.size.width - 20,
                                    height: 50,
                                    alignment: .center
                                )
                                .background(Theme.btnColor(colorScheme))
                                .cornerRadius(10)
                        }
                        Button {
                            dismiss()
                        } label: {
                            HStack {
                                Text(String.ifAlreadyHaveAccount)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.defaultColor(colorScheme))
                                
                                Text(String.signIn)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Theme.textColor(colorScheme))
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.bottom, 30)
                    
                }
                .padding(.top, 50)
                .padding(.bottom, 30)
                if isRegisterInProgress {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(5)
                }
            }
            .background(Theme.bgColor(colorScheme))
            .popup(isPresented: $noBlank) {
                CustomPopUpView(
                    alertText: String.alertFillAllBlank,
                    bgColor: .red
                )
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $alreadyRegistered) {
                CustomPopUpView(
                    alertText: String.alertAlreadyRegistered,
                    bgColor: .red
                )
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $badFormatEmail) {
                CustomPopUpView(
                    alertText: String.alertInvaildEmail,
                    bgColor: .red
                )
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.top)
                    .closeOnTap(true)
                    .dragToDismiss(true)
                    .autohideIn(3)
            }
            .popup(isPresented: $badFormatPassword) {
                CustomPopUpView(
                    alertText: String.alertPasswordCountBiggerThan6,
                    bgColor: .red
                )
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
