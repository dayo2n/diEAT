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

    var body: some View {
        
        VStack {
            ProfileHeaderView(user: user)
                .padding(.top, 40)
            
            // Calendar
            CustomDatePicker(currentDate: $currentDate)
                .padding([.leading, .trailing] ,10)
            
            // Eat Log
            
            Spacer()
        }
        .ignoresSafeArea()
        .background(Color("bgColor"))
    }
}
