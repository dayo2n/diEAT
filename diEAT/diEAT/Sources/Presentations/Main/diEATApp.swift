//
//  diEAT.swift
//  diEAT
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI
import FirebaseCore

@main
struct diEATApp: App {
    init() {
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AuthViewModel.shared)
                .navigationViewStyle(StackNavigationViewStyle())
                .tint(Color.accentColor)
        }
    }
}
