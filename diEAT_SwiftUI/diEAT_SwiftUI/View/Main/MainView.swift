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

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: { EditProfileView(user: user)}, label: {
                        ProfileHeaderView(user: user)
                    })
                    
                    Button(action: AuthViewModel.shared.logout) {
                        Image(systemName: scheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")
                            .padding(.trailing)
                            .foregroundColor(Theme.textColor(scheme))
                    }
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
                Text("\(user.username)님 반갑습니다 :)")
                    .font(.system(size: 17, weight: .medium, design: .monospaced))
                    .padding([.leading, .trailing], 20)
                    .padding([.bottom, .top], 10)
                    .foregroundColor(Theme.textColor(scheme))
                    .background(.blue)
                    .cornerRadius(30.0)
            }
        }
    }
}
