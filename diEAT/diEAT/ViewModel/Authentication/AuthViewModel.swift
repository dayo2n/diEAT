//
//  AuthViewModel.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/03.
//

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
    
    func register(username: String, email: String, pw: String, _ completion: @escaping(Int) -> Void?) {
        Auth.auth().createUser(withEmail: email, password: pw) { result, error in
            if let error = error {
                print("=== DEBUG: \(error.localizedDescription), \(error._code)")
                completion(error._code)
                return
            }
            
            guard let user = result?.user else { return }
            
            let data = ["email": email,
                        "username": username,
                        "uid": user.uid]
            
            Firestore.firestore().collection("users").document(user.uid).setData(data) { _ in
                completion(0)
            }
        }
    }
    
    func login(email: String, pw: String, _ completion: @escaping(Bool) -> Void?) {
        Auth.auth().signIn(withEmail: email, password: pw) { result, error in
            if let error = error {
                print("=== DEBUG: \(error.localizedDescription)")
                if error._code == 17009 {
                    completion(false)
                }
                return
            }
            
            guard let user = result?.user else { return }
            self.userSession = user
            self.fetchUser()
            completion(true)
        }
    }
    
    func logout() {
        self.userSession = nil
        try? Auth.auth().signOut()
    }

    func resetPassword(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { _ in
            
        }
    }
    
    func deleteUser() {
        guard let uid = userSession?.uid else { return }
        
        Firestore.firestore().collection("users").document(uid).delete() { _ in
            Auth.auth().currentUser?.delete() { _ in
                self.logout()
            }
        }
    }
    
    func editUsername(newUsername: String) {
        guard let uid = userSession?.uid else { return }
        Firestore.firestore().collection("users").document(uid).updateData(["username": newUsername]) { _ in
            print("=== DEBUG: new username is \(newUsername)")
        }
        fetchUser()
    }
    
    func uploadProfileImage(newProfileImage: UIImage, _ completion: @escaping () -> Void) {
        guard let uid = userSession?.uid else { return }
        ImageUploader.uploadImage(image: newProfileImage, type: .profile) { imageUrl in
            Firestore.firestore().collection("users").document(uid).updateData(["profileImageUrl": imageUrl]) { _ in
                print("=== DEBUG: profile image uploaded!")
                
                self.fetchUser()
                completion()
            }
        }
    }
}
