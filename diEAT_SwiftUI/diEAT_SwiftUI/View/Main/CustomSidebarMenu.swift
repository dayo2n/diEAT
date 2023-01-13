//
//  CustomSidebarMenu.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/11/21.
//

import SwiftUI

struct CustomSidebarMenu: View {
    
    let imageName: String
    let menuTitle: String
    
    @Environment(\.colorScheme) var scheme
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(Theme.textColor(scheme))
                .font(.system(size: 16))
            
            Text(menuTitle)
                .font(.system(size: 16, weight: .medium, design: .monospaced))
                .foregroundColor(Theme.textColor(scheme))
                .padding(.leading, 10)
            
            Spacer()
        }
        .padding(.leading, 20)
        .padding(.vertical)
    }
}
