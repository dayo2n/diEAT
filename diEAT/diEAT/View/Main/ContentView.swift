//
//  ContentView.swift
//  diEAT
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.colorScheme) var scheme
    
    @State var isInLoading = true
    
    var body: some View {
        ZStack {
            // Main view screen
            if viewModel.userSession == nil {
                LoginView()
            } else {
                if let user = viewModel.currentUser {
                    MainView(user: user)
                }
            }
            // Launch screen
            if isInLoading {
                launchScreenView
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                isInLoading.toggle()
            })
        }
    }
}

extension ContentView {
    var launchScreenView: some View {
        ZStack(alignment: .center) {
            LinearGradient(gradient: Gradient(colors: [.white]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            Image("launchScreenImage")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
    }
}
