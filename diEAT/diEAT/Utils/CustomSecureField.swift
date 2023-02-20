//
//  CustomSecureField.swift
//  diEAT
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI

struct CustomSecureField: View {
    
    @Binding var password: String
    let placeholder: Text
    
    var body: some View {
        ZStack(alignment: .leading) {
            if password.isEmpty {
                placeholder
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.leading, 40)
            }
            
            HStack {
                Spacer()
                
                Image(systemName: "lock")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                SecureField("", text: $password)
                
                Spacer()
            }
        }
    }
}
