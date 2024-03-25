//
//  ImageUploader.swift
//  diEAT
//
//  Created by 문다 on 2022/10/03.
//

import Foundation
import FirebaseStorage
import UIKit

// profile 또는 Post 타입에 따라 파일 경로 설정
enum UploadType {
    case profile
    case post
    
    var filePath : StorageReference {
        let filename = NSUUID().uuidString // unique id generator
        switch self {
        case .profile:
            return Storage.storage().reference(withPath: "/profile_images/\(filename)")
        case .post:
            return Storage.storage().reference(withPath: "/post_images/\(filename)")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage,type: UploadType, completion: @escaping(String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        let ref = type.filePath
        
        ref.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("=== DEBUG: failed to upload image \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url , _ in
                guard let imageUrl = url?.absoluteString else { return } // 함수에서 String으로 받기로 해서
                completion(imageUrl)
            }
        }
    }
}
