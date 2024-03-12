//
//  FetchPostViewModel.swift
//  diEAT
//
//  Created by 문다 on 2022/10/14.
//

import SwiftUI
import Firebase

class FetchPostViewModel: ObservableObject {
    @Published var postsByDay = [Post]()
    @Published var postsByMonth = [Post]()
    @Published var postedDates = [String]()
    
    init() {
        fetchPostByDate(selectedDate: Date.now)
        fetchPostByMonth(selectedDate: Date.now)
    }
    
    func fetchPostByDate(selectedDate: Date) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap { try? $0.data(as: Post.self) }
            let selectedDate = Date2OnlyDate(date: UTC2KST(date: selectedDate))
            self.postsByDay = posts
                .filter { Date2OnlyDate(date: $0.timestamp.dateValue()) == selectedDate }
                .sorted { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
            print("=== DEBUG: fetch posts on \(selectedDate)")
        }
    }
    
    func fetchPostByMonth(selectedDate: Date) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap { try? $0.data(as: Post.self) }
            let selectedDate = Date2OnlyMonth(date: UTC2KST(date: selectedDate))
            self.postsByMonth = posts
                .filter { Date2OnlyMonth(date: $0.timestamp.dateValue()) == selectedDate }
                .sorted { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
            print("=== DEBUG: fetch posts on \(selectedDate)")
        }
    }
    
    func fetchPostedDates() {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap{ try? $0.data(as: Post.self) }
            self.postedDates = posts
                .map { Date2OnlyDate(date: $0.timestamp.dateValue()) }
            print(self.postedDates)
        }
    }
    
    func deletePost(id: String) {
        print("=== DEBUG: delete \(id)")
        Firestore.firestore().collection("posts").document(id).delete()
    }
}
