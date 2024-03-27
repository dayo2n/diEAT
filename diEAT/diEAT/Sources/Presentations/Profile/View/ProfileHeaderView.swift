//
//  ProfileHeaderView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    
    let user: User
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        HStack {
            ProfileImageView(user: user, size: CGSize(width: 70, height: 70))
            Text(user.username)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.textColor(scheme))
                .padding(.leading)
            
            Spacer()
        }
        .padding(.top, 30)
    }
}
