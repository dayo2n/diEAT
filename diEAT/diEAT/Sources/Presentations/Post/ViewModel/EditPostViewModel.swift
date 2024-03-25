//
//  PostViewModel.swift
//  diEAT
//
//  Created by 문다 on 2022/10/12.
//

import SwiftUI
import Firebase

typealias FirestoreCompletion = ((Error?) -> Void)?

class EditPostViewModel: ObservableObject{
    
    func uploadPost(selectedDate: Date, image: UIImage, caption: String, mealtime: String, icon: String?, completion: FirestoreCompletion) {
        guard let user = AuthViewModel.shared.currentUser else { return }
        ImageUploader.uploadImage(image: image, type: .post) { imageUrl in
            let data = [
                "uid": user.id,
                "username": user.username,
                "imageUrl": imageUrl,
                "caption": caption,
                "timestamp": Timestamp(date: selectedDate),
                "mealtime": mealtime,
                "icon": icon
            ] as [String: Any]
            Firestore.firestore().collection("posts").addDocument(data: data, completion: completion)
        }
    }
    
    func updatePost(id: String, selectedDate: Date, image: UIImage, caption: String, mealtime: String, icon: String?, completion: FirestoreCompletion) {
        print("=== DEBUG: update \(id)")
        Firestore.firestore().collection("posts").document(id).delete() { _ in
            self.uploadPost(
                selectedDate: selectedDate,
                image: image,
                caption: caption,
                mealtime: mealtime,
                icon: icon,
                completion: completion
            )
        }
    }
}
