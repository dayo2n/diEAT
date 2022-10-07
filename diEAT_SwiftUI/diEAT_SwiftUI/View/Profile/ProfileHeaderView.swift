//
//  ProfileHeaderView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import Kingfisher

struct ProfileHeaderView: View {
    
    let user: User
    
    var body: some View {
        HStack {
            if let profileImageUrl = user.profileImageUrl {
                KFImage(URL(string: profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .padding(.leading)
            } else {
                Image("defaultProfileImg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .padding(.leading)
            }
            
            Text("\(user.username)")
            
            Spacer()
        }.padding([.top, .bottom], 20)
    }
}
