//
//  EditProfileView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/07.
//

import SwiftUI
import Kingfisher

struct EditProfileView: View {
    @ObservedObject var viewModel: AuthViewModel
    var body: some View {
        VStack {
            if let profileImgUrl = viewModel.currentUser?.profileImageUrl {
                    KFImage(URL(string: profileImgUrl))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.leading)
            } else {
                Image("defaultProfileImg")
                
                    Image("defaultProfileImg")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .padding(.leading)
            }
        }
    }
}
