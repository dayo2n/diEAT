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
                        imageName: "person.fill.viewfinder",
                        menuTitle: "회원정보 수정"
                    )
                }
                .sheet(isPresented: $showEditProfile) {
                    EditProfileView(user: user)
                }
                
                Button(action: AuthViewModel.shared.logout) {
                    CustomSidebarMenu(imageName: "\(colorScheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")",
                                      menuTitle: "로그아웃")
                }
                
                Divider()
                    .padding(.all)
                
                Spacer()
                
                Button {
                    showInquiry.toggle()
                } label: {
                    CustomSidebarMenu(imageName: "macwindow", menuTitle: "문의 및 버그 제보")
                }
                .sheet(isPresented: $showInquiry, content: { InquiryView() })
                
                Divider()
                
                // 개발자 정보
                Button {
                    if let url = URL(string: "https://github.com/dayo2n") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    HStack {
                        Image("octocat")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        
                        Text("Github @dayo2n")
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
