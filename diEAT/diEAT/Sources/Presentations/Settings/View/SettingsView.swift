//
//  SettingsView.swift
//  diEAT
//
//  Created by 제나 on 3/12/24.
//

import SwiftUI

struct SettingsView: View {
    
    let user: User
    @Environment(\.colorScheme) private var colorScheme
    @State private var showEditProfile = false
    @State private var showInquiry = false
    var body: some View {
        NavigationView {
            VStack {
                ProfileHeaderView(user: user)
                
                Divider()
                    .padding(.all)
                
                Button {
                    showEditProfile.toggle()
                } label: {
                    CustomSidebarMenu(
                        imageName: String.personFillViewfinder,
                        menuTitle: String.editUserInformation
                    )
                }
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView(user: user)
                }
                
                Button(action: AuthViewModel.shared.logout) {
                    CustomSidebarMenu(
                        imageName: colorScheme == .dark ?
                        String.rectanglePortraitAndArrowRightFill
                        : String.rectanglePortraitAndArrowRight,
                        menuTitle: String.signOut
                    )
                }
                
                Divider()
                    .padding(.all)
                
                Spacer()
                
                Button {
                    showInquiry.toggle()
                } label: {
                    CustomSidebarMenu(
                        imageName: String.macwindow,
                        menuTitle: String.inquiryOrBugReport
                    )
                }
                .sheet(isPresented: $showInquiry) {
                    InquiryView()
                }
                
                Divider()
                
                // 개발자 정보
                Button {
                    if let url = URL(string: String.githubUrl) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image(String.octocat)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        
                        Text(String.githubId)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .foregroundColor(Theme.textColor(colorScheme))
                    .padding(.leading, 20)
                    .padding(.vertical)
                }
            }
            .background(Theme.bgColor(colorScheme))
        }
    }
}
