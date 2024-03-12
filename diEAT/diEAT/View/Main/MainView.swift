//
//  MainView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import PopupView

struct MainView: View {
    
    let user: User
    @State var currentDate = Date()
    @State var selectedDate = Date()
    @Environment(\.colorScheme) var scheme
    @StateObject var viewModel = FetchPostViewModel()
    
    // show flag
    @State private var popLoginToast = false
    @State private var freezePop = false
    @State private var showSidebar = false
    @State private var showEditProfile = false
    @State private var showInquiry = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Sidebar button, Calendar
                CustomDatePicker(
                    currentDate: $currentDate,
                    selectedDate: $selectedDate,
                    showSidebar: $showSidebar,
                    viewModel: viewModel
                )
                .foregroundColor(Theme.textColor(scheme))
                .padding([.leading, .trailing], 10)
                .onChange(of: selectedDate) { value in
                    selectedDate = value
                }
                
                // Eat log
                EatLog(
                    selectedDate: $selectedDate,
                    viewModel: viewModel
                )
            }
            .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
            .background(Theme.bgColor(scheme))
            .onAppear {
                viewModel.fetchPostedDates()
                if !freezePop {
                    popLoginToast.toggle()
                    freezePop = true
                }
            }
            // login 인사
            .popup(isPresented: $popLoginToast) {
                CustomPopUpView(alertText: "\(user.username)님 반갑습니다 :)", bgColor: .blue)
            } customize: { pop in
                pop
                    .type(.floater())
                    .position(.bottom)
                    .dragToDismiss(true)
                    .closeOnTap(true)
                    .autohideIn(3)
            }
            .gesture(
                DragGesture(
                    minimumDistance: 10,
                    coordinateSpace: .local
                )
                .onEnded{ value in
                    if showSidebar {
                        if value.translation.width < 0 { // left 방향으로 슬라이드하면
                            showSidebar.toggle()
                        }
                    } else {
                        if value.translation.width > 0 { // right 방향으로 슬라이드하면
                            showSidebar.toggle()
                        }
                    }
                }
            )
        }
        // 사이드바 메뉴 구성
        //        SidebarMenu(
        //            sidebarWidth: UIScreen.main.bounds.width / 3 * 2,
        //            showSidebar: $showSidebar
        //        ) {
        //            NavigationView {
        //                VStack {
        //                    ProfileHeaderView(user: user)
        //                    
        //                    Divider()
        //                        .padding(.all)
        //                    
        //                    Button {
        //                        showEditProfile.toggle()
        //                    } label: {
        //                        CustomSidebarMenu(
        //                            imageName: "person.fill.viewfinder",
        //                            menuTitle: "회원정보 수정"
        //                        )
        //                    }
        //                    .sheet(isPresented: $showEditProfile) {
        //                        EditProfileView(user: user)
        //                    }
        //                    
        //                    Button(action: AuthViewModel.shared.logout) {
        //                        CustomSidebarMenu(imageName: "\(scheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")",
        //                                          menuTitle: "로그아웃")
        //                    }
        //                    
        //                    Divider()
        //                        .padding(.all)
        //                    
        //                    Spacer()
        //                    
        //                    Button(action: { showInquiry.toggle() }) {
        //                        CustomSidebarMenu(imageName: "macwindow", menuTitle: "문의 및 버그 제보") }
        //                    .sheet(isPresented: $showInquiry, content: { InquiryView() })
        //                    
        //                    Divider()
        //                    
        //                    // 개발자 정보
        //                    Button(action: {}, label: {
        //                        HStack {
        //                            Image("octocat")
        //                                .renderingMode(.template)
        //                                .resizable()
        //                                .scaledToFit()
        //                                .frame(width: 16)
        //                            
        //                            Text("Github @dayo2n")
        //                                .font(.system(size: 12, weight: .medium, design: .monospaced))
        //                                .padding(.leading, 10)
        //                            
        //                            Spacer()
        //                        }
        //                        .foregroundColor(Theme.textColor(scheme))
        //                        .padding(.leading, 20)
        //                        .padding(.vertical)
        //                    })
        //                }
        //            }
        //            .gesture(
        //                DragGesture(
        //                    minimumDistance: 10,
        //                    coordinateSpace: .local
        //                )
        //                .onEnded{ value in
        //                    if showSidebar {
        //                        if value.translation.width < 0 { // left 방향으로 슬라이드하면
        //                            showSidebar.toggle()
        //                        }
        //                    }
        //                }
        //            )
        //        } content: {
        //            // 메인 뷰
        //
        //        }
        //        .edgesIgnoringSafeArea(.all)
    }
}
