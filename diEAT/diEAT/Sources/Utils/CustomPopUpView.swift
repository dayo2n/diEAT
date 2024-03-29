//
//  CustomPopUpView.swift
//  diEAT
//
//  Created by 문다 on 2022/11/23.
//

import SwiftUI

struct CustomPopUpView: View {
    let alertText: String
    let bgColor: Color
    @Environment(\.colorScheme) var scheme
    var body: some View {
        Text(alertText)
            .font(.system(size: 17, weight: .medium, design: .monospaced))
            .padding([.leading, .trailing], 20)
            .padding([.bottom, .top], 10)
            .foregroundColor(.white)
            .background(bgColor)
            .cornerRadius(30.0)
            .multilineTextAlignment(.center)
    }
}
