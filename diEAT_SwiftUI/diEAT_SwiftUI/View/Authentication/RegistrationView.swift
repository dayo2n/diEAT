//
//  RegistrationView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var id: String = ""
    @State private var pw: String = ""
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.presentationMode) var mode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("diEAT")
                    .font(.system(size: 30, weight: .heavy, design: .monospaced))
                Text("Sign up")
                    .font(.system(size: 13, weight: .light, design: .monospaced))
                
                Spacer()
                VStack {
                    CustomTextField(text: $id, placeholder: Text("USERNAME"), imageName: "person")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Color("btnColor"), width: 0.7)
                        .padding([.leading, .trailing])
                    
                    CustomTextField(text: $id, placeholder: Text("ID"), imageName: "heart.text.square")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .padding(20)
                        .frame(height: 50)
                        .border(Color("btnColor"), width: 0.7)
                        .padding([.leading, .trailing])
                    
                    CustomSecureField(password: $id, placeholder: Text("PASSWORD"))
                        .padding(20)
                        .frame(height: 50)
                        .border(Color("btnColor"), width: 0.7)
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 20)
                    
                    Button(action: {viewModel.login()}, label: {
                        Text("SIGN UP")
                            .font(.system(size: 15, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.size.width - 20 ,height: 50, alignment: .center)
                            .background(Color("btnColor"))
                            .cornerRadius(10)
                    })
                    
                    Button(action: { mode.wrappedValue.dismiss() }, label: {
                        HStack {
                            Text("Already have an account?")
                                .font(.system(size: 13))
                                .foregroundColor(.black)
                            
                            Text("Sign in")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                        }
                        .padding(.bottom, 16)
                    })
                }.padding(.bottom, 30)
            }
        }
        .ignoresSafeArea()
        .background(Color("bgColor"))
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
