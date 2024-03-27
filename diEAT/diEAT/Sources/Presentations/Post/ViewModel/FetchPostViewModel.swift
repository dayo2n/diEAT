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
        fetchPostData(selectedDate: Date.now)
    }
    
    func fetchPostData(selectedDate: Date) {
        fetchPostByDate(selectedDate: selectedDate)
        fetchPostByMonth(selectedDate: selectedDate)
        fetchPostedDates()
    }
    
    func fetchPostByDate(selectedDate: Date) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap { try? $0.data(as: Post.self) }
            let selectedDate = selectedDate.utc2kst.date2OnlyDate
            self.postsByDay = posts
                .filter { $0.timestamp.dateValue().date2OnlyDate == selectedDate }
                .sorted { $0.timestamp.dateValue() < $1.timestamp.dateValue() }
            print("=== DEBUG: fetch posts on \(selectedDate)")
        }
    }
    
    func fetchPostByMonth(selectedDate: Date) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap { try? $0.data(as: Post.self) }
            let selectedDate = selectedDate.utc2kst.date2OnlyMonth
            self.postsByMonth = posts
                .filter { $0.timestamp.dateValue().date2OnlyMonth == selectedDate }
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
                .map { $0.timestamp.dateValue().date2OnlyDate }
            print(self.postedDates)
        }
    }
    
    func deletePost(id: String, _ completion: @escaping() -> Void) {
        print("=== DEBUG: delete \(id)")
        Firestore.firestore().collection("posts").document(id).delete() { _ in
            completion()
        }
    }
}
