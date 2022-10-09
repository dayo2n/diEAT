//
//  MainView.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/05.
//

import SwiftUI
import ElegantCalendar

struct MainView: View {
    
    @ObservedObject var viewModel: AuthViewModel
    @State var currentDate: Date = Date()
    @State var editProfileMode: Bool = false
    @Environment(\.colorScheme) var scheme

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    NavigationLink(destination: { EditProfileView(viewModel: viewModel )}, label: {
                        ProfileHeaderView(user: viewModel.currentUser!)
                    })
                    
                    Button(action: AuthViewModel.shared.logout) {
                        Image(systemName: scheme == .dark ? "rectangle.portrait.and.arrow.right.fill" : "rectangle.portrait.and.arrow.right")
                            .padding(.trailing)
                            .foregroundColor(Theme.textColor(scheme))
                    }
                }
                
                // Calendar
                CustomDatePicker(currentDate: $currentDate)
                    .foregroundColor(Theme.textColor(scheme))
                    .padding([.leading, .trailing] ,10)
                
                // Eat Log
                
                Spacer()
                
            }
            .edgesIgnoringSafeArea([.bottom, .trailing, .leading])
            .background(Theme.bgColor(scheme))
        }
    }
}
