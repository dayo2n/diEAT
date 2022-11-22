//
//  MainView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import PopupView

struct MainView: View {
    
    let user: User
    @State var currentDate: Date = Date()
    @State var selectedDate: Date = Date()
    @Environment(\.colorScheme) var scheme
    @ObservedObject var viewModel: FetchPostViewModel = FetchPostViewModel()
    @State private var popLoginToast: Bool = false
    @State private var freezePop: Bool = false
    @State var showSidebar: Bool = false
    @State var showEditProfile: Bool = false

    var body: some View {
        SidebarMenu(sidebarWidth: UIScreen.main.bounds.width / 3 * 2, showSidebar: $showSidebar) {
            NavigationView {
                VStack {
                    ProfileHeaderView(user: user)

                    Divider()
                        .padding(.all)
                    
                    Button(action: { showEditProfile.toggle() }, label: {
                        CustomSidebarMenu(imageName: "person.fill.viewfinder", menuTitle: "프로필 수정")
                    })
                        .sheet(isPresented: $showEditProfile, content: { EditProfileView(user: user) })

                    Divider()
                        .padding(.all)
                    
                    Button(action: AuthViewModel.shared.logout) {
                        CustomSidebarMenu(imageName: "\(scheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")",
                                          menuTitle: "로그아웃")
                    }
                    
                    Spacer()
                    
                    Divider()
                    
                    Button(action: {}, label: {
                        CustomSidebarMenu(imageName: "person.crop.circle.fill.badge.xmark", menuTitle: "회원 탈퇴")
                    })
                    
                    // 개발자 정보
                    HStack {
                        Image("octocat")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16)
                        
                        Text("github.com/dayo2n")
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .padding(.leading, 10)
                        
                        Spacer()
                    }
                    .foregroundColor(Theme.textColor(scheme))
                    .padding(.leading, 20)
                    .padding(.vertical)
                    .padding(.bottom, 30)
                }
            }
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                .onEnded({ value in
                    if showSidebar {
                        if value.translation.width < 0 { // left 방향으로 슬라이드하면
                            showSidebar.toggle()
                        }
                    }
                }))
        } content: {
            NavigationView {
                VStack {
                    HStack {
                        Button(action: {
                            showSidebar.toggle()
                        }) {
                            Image(systemName: "text.justify")
                                .font(.system(size: 20))
                                .frame(width: 44, height: 44)
                                .padding(.all)
                                .foregroundColor(Theme.textColor(scheme))
                        }
                        Spacer()
                    }
                    
                    // Calendar
                    CustomDatePicker(currentDate: $currentDate, selectedDate: $selectedDate, viewModel: viewModel)
                        .foregroundColor(Theme.textColor(scheme))
                        .padding([.leading, .trailing], 10)
                        .padding(.bottom, 20)
                        .onChange(of: selectedDate, perform: { value in selectedDate = value })
                    
                    // Eat log
                    EatLog(selectedDate: $selectedDate, viewModel: viewModel)
                }
                .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
                .background(Theme.bgColor(scheme))
                .onAppear() {
                    viewModel.fetchPost(selectedDate: selectedDate)
                    if !freezePop {
                        popLoginToast.toggle()
                        freezePop = true
                    }
                }
                .popup(isPresented: $popLoginToast, type: .floater(), position: .bottom, autohideIn: 3) {
                    CustomPopUpView(alertText: "\(user.username)님 반갑습니다 :)", bgColor: .blue)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
