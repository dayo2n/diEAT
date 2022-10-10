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
    
    func register(username: String, email: String, pw: String) {
        Auth.auth().createUser(withEmail: email, password: pw) { result, error in
            if let error = error {
                print("=== DEBUG: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            
            let data = ["email": email,
                        "username": username,
                        "uid": user.uid]
            
            Firestore.firestore().collection("users").document(user.uid).setData(data) { _ in
                self.userSession = user
                self.fetchUser()
            }
        }
    }
    
    func login(email: String, pw: String) {
        Auth.auth().signIn(withEmail: email, password: pw) { result, error in
            if let error = error {
                print("=== DEBUG: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            self.userSession = user
            self.fetchUser()
        }
    }
    
    func logout() {
        self.userSession = nil
        try? Auth.auth().signOut()
    }

    func resetPassword() {
        
    }
    
    func editUsername(newUsername: String) {
        guard let uid = userSession?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData(["username": newUsername]) { _ in
            print("=== DEBUG: new username is \(newUsername)")
        }
        fetchUser()
    }
    
    func uploadProfileImage(newProfileImage: UIImage) {
        guard let uid = userSession?.uid else { return }
        ImageUploader.uploadImage(image: newProfileImage, type: .profile) { imageUrl in
            Firestore.firestore().collection("users").document(uid).updateData(["profileImageUrl": imageUrl]) { _ in
                print("=== DEBUG: profile image uploaded!")
                
                self.fetchUser()
            }
        }
    }
}
