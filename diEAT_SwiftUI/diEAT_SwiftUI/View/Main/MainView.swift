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
    
    // show flag
    @State private var popLoginToast: Bool = false
    @State private var freezePop: Bool = false
    @State private var showSidebar: Bool = false
    @State private var showEditProfile: Bool = false
    @State private var showInquiry: Bool = false

    var body: some View {
        // 사이드바 메뉴 구성
        SidebarMenu(sidebarWidth: UIScreen.main.bounds.width / 3 * 2, showSidebar: $showSidebar) {
            NavigationView {
                VStack {
                    ProfileHeaderView(user: user)

                    Divider()
                        .padding(.all)
                    
                    Button(action: { showEditProfile.toggle() }, label: {
                        CustomSidebarMenu(imageName: "person.fill.viewfinder", menuTitle: "회원정보 수정")
                    })
                    .sheet(isPresented: $showEditProfile, content: { EditProfileView(user: user) })
                    
                    Button(action: AuthViewModel.shared.logout) {
                        CustomSidebarMenu(imageName: "\(scheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")",
                                          menuTitle: "로그아웃")
                    }

                    Divider()
                        .padding(.all)
                    
                    Spacer()
                    
                    Button(action: { showInquiry.toggle() }) {
                        CustomSidebarMenu(imageName: "macwindow", menuTitle: "문의 및 버그 제보") }
                    .sheet(isPresented: $showInquiry, content: { InquiryView() })
                    
                    Divider()
                    
                    // 개발자 정보
                    Button(action: {}, label: {
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
                    })
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
            // 메인 뷰
            NavigationView {
                VStack {
                    HStack {
                        // open side menu bar
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
                // login 인사
                .popup(isPresented: $popLoginToast, type: .floater(), position: .bottom, autohideIn: 3) {
                    CustomPopUpView(alertText: "\(user.username)님 반갑습니다 :)", bgColor: .blue)
                }
            }
        }.edgesIgnoringSafeArea(.all)
    }
}
