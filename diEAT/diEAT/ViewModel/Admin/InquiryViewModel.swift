//
//  InquiryViewModel.swift
//  diEAT
//
//  Created by 문다 on 2022/11/23.
//

import SwiftUI
import Firebase

class InquiryViewModel: ObservableObject {
    func uploadInquiry(title: String, contents: String, completion: FirestoreCompletion) {
        guard let user = AuthViewModel.shared.currentUser else { return }
        let data = ["uid": user.id,
                    "writerEmail": user.email,
                    "title": title,
                    "contents": contents] as [String: Any]
        Firestore.firestore().collection("inquiries").addDocument(data: data, completion: completion)
    }
}
