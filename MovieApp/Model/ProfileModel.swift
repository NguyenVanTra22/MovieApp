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

struct Profile: Decodable {
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
