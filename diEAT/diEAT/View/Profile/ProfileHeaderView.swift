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
            if let profileImageUrl = user.profileImageUrl {
                KFImage(URL(string: profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .padding(.leading)
            } else {
                Image("defaultProfileImg")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.leading)
                    .foregroundColor(Theme.textColor(scheme))
            }
            
            Text("\(user.username)")
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundColor(Theme.textColor(scheme))
                .padding(.leading)
            
            Spacer()
        }.padding(.top, 30)
    }
}
