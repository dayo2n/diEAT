//
//  AuthViewModel.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/03.
//

import SwiftUI
import Firebase

class AuthViewModel: ObservableObject {
    
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    static let shared = AuthViewModel()
    
    init() {
        userSession = Auth.auth().currentUser // makes a API call to the firebase server
        // If there is no login information, userSession would be 'nil'
        fetchUser()
    }
    
    func fetchUser () {
        guard let uid = userSession?.uid else { return }
        print("=== DEBUG: fetch user \(uid)")
        Firestore.firestore().collection("users").document(uid).getDocument { snapshot , _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            
            self.currentUser = user
        }
    }
    
    func register() {
        
    }
    
    func login() {
        
    }
    
    func logout() {
        self.userSession = nil
        try? Auth.auth().signOut()
    }

    func resetPassword() {
        
    }
}
