//
//  User.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/10/03.
//

import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    var username: String
    let email: String
    let profileImageUrl: String?
    @DocumentID var id: String?
}
