//
//  CustomTextField.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI

struct CustomTextField: View {
    
    @Binding var text: String
    let placeholder: Text
    let imageName: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                placeholder
                    .font(.system(size: 15, weight: .medium, design: .monospaced))
                    .padding(.leading, 40)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Spacer()
                
                Image(systemName: imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                
                TextField("", text: $text)
                    .disableAutocorrection(true)
                
                Spacer()
            }
        }
    }
}
