//
//  StorageManager.swift
//  englishMessenger
//
//  Created by Данила on 19.02.2023.
//

import Foundation
import FirebaseStorage

final class StorageManager {

    static let shared = StorageManager()
    private let storage = Storage.storage().reference()

    /*
     /images/d-viltsev-gmail-com_profile_picture.png
     */

    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void


    /// Uploads pictures to firebase storage and returns completion with url string to download

    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
            guard error == nil else {
                // failed
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
