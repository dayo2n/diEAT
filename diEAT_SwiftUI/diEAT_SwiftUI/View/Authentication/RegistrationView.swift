//
//  RegistrationView.swift
//  diEAT_SwiftUI
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
    
    // alert flag
    @State private var showAlert: Bool = false
    @State private var alreadyRegistered: Bool = false
    
    var body: some View {
        NavigationView {
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
                        .padding([.top, .bottom], 20)
                    
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
                        .padding([.top, .bottom], 20)
                    
                    Button(action: {
                        if username.count == 0 || email.count == 0 || pw.count == 0 { showAlert.toggle() }
                        else { viewModel.register(username: username, email: email, pw: pw) { bool in
                            if !bool { alreadyRegistered.toggle() }
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
            .popup(isPresented: $showAlert, type: .floater(), position: .top, autohideIn: 3) {
                CustomPopUpView(alertText: "항목을 모두 작성해주세요!", bgColor: .red)
            }
            .popup(isPresented: $alreadyRegistered, type: .floater(), position: .top, autohideIn: 3) {
                CustomPopUpView(alertText: "이미 가입되어 있는 이메일입니다.", bgColor: .red)
            }
        }
        .ignoresSafeArea()
        .background(Color("bgColor"))
    }
}
