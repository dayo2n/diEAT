//
//  FetchPostViewModel.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/14.
//

import SwiftUI
import Firebase

class FetchPostViewModel: ObservableObject {
    @Published var posts: [Post] = [Post]()
    
    func fetchPost(selectedDate: Date) {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments {snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap({ try? $0.data(as: Post.self) })
            self.posts = posts.filter{ Date2OnlyDate(date: $0.timestamp.dateValue()) == Date2OnlyDate(date: UTC2KST(date: selectedDate)) }
//                .sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
            
            print("=== DEBUG: fetch posts on \(UTC2KST(date: selectedDate))")
        }
    }
}
