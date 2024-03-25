//
//  CustomIconButton.swift
//  diEAT
//
//  Created by 문다 on 2022/11/19.
//

import SwiftUI

struct CustomIcon: View {
    
    let iconName: String
    var body: some View {
        Image(iconName)
            .resizable()
            .scaledToFit()
            .frame(width: 44, height: 44)
            .padding(.horizontal)
    }
}
