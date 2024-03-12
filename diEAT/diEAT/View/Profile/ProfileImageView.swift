//
//  ProfileImageView.swift
//  diEAT
//
//  Created by 제나 on 3/12/24.
//

import SwiftUI
import Kingfisher

struct ProfileImageView: View {
    
    let user: User
    @Environment(\.colorScheme) private var colorScheme
    let size: CGSize
    
    var body: some View {
        if let profileImageUrl = user.profileImageUrl {
            KFImage(URL(string: profileImageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: 0.3)
                )
                .padding(.leading)
        } else {
            Image("defaultProfileImg")
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                .clipShape(Circle())
                .padding(.leading)
                .foregroundColor(Theme.textColor(colorScheme))
        }
    }
}
