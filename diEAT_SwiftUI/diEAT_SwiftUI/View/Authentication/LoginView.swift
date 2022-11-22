//
//  LoginView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI

struct LoginView: View {
    
    @State private var email: String = ""
    @State private var pw: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var scheme
    
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
                    
                    Button(action: { viewModel.login(email: email, pw: pw) }, label: {
                        Text("LOGIN")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(Theme.textColor(scheme))
                            .frame(width: UIScreen.main.bounds.size.width - 20 ,height: 50, alignment: .center)
                            .background(Theme.btnColor(scheme))
                            .cornerRadius(10)
                    })
                    
                    NavigationLink(destination: RegistrationView().navigationBarHidden(true), label: {
                        HStack {
                            Text("Don't have an account?")
                                .font(.system(size: 13))
                                .foregroundColor(Theme.defaultColor(scheme))
                            
                            Text("Sign up")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Theme.textColor(scheme))
                        }
                        .padding(.bottom, 16)
                    })
                }.padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
        .background()
        .background(Theme.bgColor(scheme))
    }
}
