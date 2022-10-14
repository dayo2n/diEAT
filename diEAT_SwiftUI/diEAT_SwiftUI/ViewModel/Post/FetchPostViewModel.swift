//
//  FetchPostViewModel.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/14.
//

import SwiftUI
import Firebase

struct FetchPostViewModel: View {
    @Published var posts: [Post]?
    
    func fetchPost(selectedDate: Date, uid: String) {
        Firestore.firestore().collection("posts").whereField("uid", isEqualTo: uid).getDocuments {snapshot, _ in
            guard let documents = snapshot?.documents else { return }
            let posts = documents.compactMap({ try? $0.data(as: Post.self) })
            self.posts = posts.filter{ $0.timestamp.dateValue() == selectedDate }.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
        }
    }
}
