//
//  ContentView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        if viewModel.userSession == nil {
            LoginView()
        } else {
            if let user = viewModel.currentUser {
                MainView(user: user)
            }
        }
    }
}
