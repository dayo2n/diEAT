//
//  MainView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import ElegantCalendar

struct MainView: View {
    
    let user: User
    @State var currentDate: Date = Date()
    @State var selectedDate: Date = Date()
    @State var editPostMode: Bool = false
    @Environment(\.colorScheme) var scheme
    @State var selectedDateChanged: Bool = false
    @ObservedObject var viewModel: FetchPostViewModel = FetchPostViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: { EditProfileView(user: user )}, label: {
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
                
                // Eat log
                EatLog(editPostMode: editPostMode, selectedDate: selectedDate, viewModel: viewModel)
            }
            .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
            .background(Theme.bgColor(scheme))
        }
    }
}
