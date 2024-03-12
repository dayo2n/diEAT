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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack {
                        CustomDatePicker(
                            currentDate: $currentDate,
                            selectedDate: $selectedDate,
                            viewModel: viewModel
                        )
                        .foregroundColor(Theme.textColor(scheme))
                        .padding([.leading, .trailing], 10)
                        .onChange(of: selectedDate) { value in
                            selectedDate = value
                        }
                        
                        VStack {
                            HStack {
                                NavigationLink {
                                    SettingsView(user: user)
                                } label: {
                                    ProfileImageView(
                                        user: user,
                                        size: CGSize(
                                            width: 40,
                                            height: 40
                                        )
                                    )
                                }
                                Spacer()
                            }
                            Spacer()
                        }
                        .padding(5)
                    }

                    // Eat log
                    EatLog(
                        selectedDate: $selectedDate,
                        viewModel: viewModel
                    )
                }
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
        }
    }
}
