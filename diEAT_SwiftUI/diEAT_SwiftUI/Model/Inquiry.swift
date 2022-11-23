//
//  Inquiry.swift
//  diEAT_SwiftUI
//
//  Created by 문다 on 2022/11/23.
//

import Firebase
import FirebaseFirestoreSwift

struct Inquiry: Identifiable, Decodable {
    @DocumentID var id: String?
    let uid: String
    let writerEmail: String
    let title: String
    let contents: String
}
