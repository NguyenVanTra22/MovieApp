//
//  Profile.swift
//  MovieApp
//
//  Created by Developer 1 on 24/09/2024.
//

//import Foundation
//
//struct Profile {
//    let name: String
//    let dob: String
//    let profileImageUrl: String
//
//    init?(json: [String: Any]) {
//        // Ánh xạ dữ liệu JSON vào các thuộc tính
//        guard let fields = json["fields"] as? [String: Any],
//              let nameField = fields["name"] as? [String: Any],
//              let name = nameField["stringValue"] as? String,
//              let dobField = fields["dob"] as? [String: Any],
//              let dob = dobField["stringValue"] as? String,
//              let imageField = fields["profileImageUrl"] as? [String: Any],
//              let imageUrl = imageField["stringValue"] as? String else {
//            return nil
//        }
//        self.name = name
//        self.dob = dob
//        self.profileImageUrl = imageUrl
//    }
//}
import Foundation
import FirebaseFirestore
import FirebaseStorage
import RxSwift
import Alamofire

struct Profile {
    let name: String
    let dob: String
    let profileImageUrl: String

    // Khởi tạo từ JSON của Firestore
    init?(json: [String: Any]) {
        guard let nameField = json["name"] as? [String: Any],
              let name = nameField["stringValue"] as? String,
              let dobField = json["dob"] as? [String: Any],
              let dob = dobField["stringValue"] as? String,
              let profileImageUrlField = json["profileImageUrl"] as? [String: Any],
              let profileImageUrl = profileImageUrlField["stringValue"] as? String else {
            return nil
        }
        self.name = name
        self.dob = dob
        self.profileImageUrl = profileImageUrl
    }
}


class ProfileModel {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    // Lưu thông tin profile vào Firestore
    func saveProfileToFirestore(userID: String, name: String, dob: String, imageUrl: URL) -> Observable<Void> {
        return Observable.create { observer in
            let profileData: [String: Any] = [
                "name": name,
                "dob": dob,
                "profileImageUrl": imageUrl.absoluteString
            ]
            self.db.collection("users").document(userID).setData(profileData) { error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // Lưu ảnh vào Firebase Storage
    func saveImageToStorage(userID: String, imageData: Data) -> Observable<URL> {
        return Observable.create { observer in
            let imageRef = self.storage.child("profile_images/\(userID).jpg")
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                imageRef.downloadURL { url, error in
                    if let error = error {
                        observer.onError(error)
                    } else if let url = url {
                        observer.onNext(url)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    // Lấy thông tin profile từ Firestore và trả về dưới dạng Profile
    func fetchProfileData(userID: String, token: String) -> Observable<Profile> {
        let baseUrl = "https://firestore.googleapis.com/v1/projects/movieapp-74975/databases/(default)/documents/users"
        let profileUrl = "\(baseUrl)/\(userID)"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        return Observable.create { observer in
            AF.request(profileUrl, method: .get, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let data):
                    if let json = data as? [String: Any],
                       let fields = json["fields"] as? [String: Any],
                       let profile = Profile(json: fields) {
                        observer.onNext(profile)
                        observer.onCompleted()
                    } else {
                        observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]))
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
