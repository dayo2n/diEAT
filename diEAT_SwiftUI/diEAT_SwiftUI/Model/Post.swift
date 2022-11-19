//
//  Post.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/12.
//
import Firebase
import FirebaseFirestoreSwift

struct Post: Identifiable, Decodable {
    @DocumentID var id: String?
    let uid: String
    let username: String
    let caption: String
    let imageUrl: String
    let timestamp: Timestamp // must be import Firebase
    let mealtime: String
    let icon: String?
}
