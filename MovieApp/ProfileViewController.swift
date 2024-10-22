//
//  ProfileViewController.swift
//  MovieApp
//
//  Created by Developer 1 on 15/10/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Alamofire
import RxSwift
import RxCocoa

struct Profile2: Decodable {
    let fields: Fields

    struct Fields: Decodable {
        let name: StringValue
        let dob: StringValue
        let profileImageUrl: StringValue
    }

    struct StringValue: Decodable {
        let stringValue: String
    }
}
//struct Profile3: Codable {
//        var name: String?
//        var dob: String?
//        var profileImageUrl: String?
//        init (name: String, dob: String, profileImagrUrl: String){
//            self.name = name
//            self.dob = dob
//            self.profileImageUrl = profileImagrUrl
//        }
//    enum CodingKeys: String, CodingKey {
//            case name
//            case dob
//            case profileImageUrl = "profileImageUrl"
//
//        }
//}

// Tạo Struct Profile2 khớp với các trường dữ liệu trên FireStore, sử dụng Alamofire trong load thông tin từ FireStore về, Sử dụng Rx để fetch data.
class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tfDOB: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    var userID: String?
    //var userEmail: String?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUserID = Auth.auth().currentUser?.uid {
            userID = currentUserID
            print(userID ?? "Khong co UserID")
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)

        Auth.auth().currentUser?.getIDToken { token, error in
            if let error = error {
                print("Lỗi lấy token: \(error.localizedDescription)")
                return
            }
            //print(token ?? ".xxxxxxxx")
            guard let token = token else {
                print("Không lấy được token")
                return
            }
            
            self.fetchProfileData(withToken: token)
                .subscribe(
                    onNext: {
                        print("Load Data thanh cong")
                    },
                    onError: { error in
                        print("Error fetching profile data: \(error.localizedDescription)")
                    }
                )
                .disposed(by: self.disposeBag)
            

        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
        
    @IBAction func selectedImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveProfile(_ sender: Any) {
        guard let name = tfName.text, !name.isEmpty,
              let dob = tfDOB.text, !dob.isEmpty,
              let image = imageView.image,
              let userID = userID else {
            print("Thông tin chưa đầy đủ hoặc chưa xác định user ID")
            return
        }

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageRef = storage.child("profile_images/\(userID).jpg")
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                guard error == nil else {
                    print("Lỗi lưu ảnh: \(error!.localizedDescription)")
                    return
                }

                imageRef.downloadURL { url, error in
                    guard let url = url, error == nil else {
                        print("Lỗi lấy URL ảnh: \(error!.localizedDescription)")
                        return
                    }

                    let profileData: [String: Any] = [
                        "name": name,
                        "dob": dob,
                        "profileImageUrl": url.absoluteString
                    ]
                    self.db.collection("users").document(userID).setData(profileData) { error in
                        if let error = error {
                            print("Lỗi lưu thông tin: \(error.localizedDescription)")
                        } else {
                            print("Lưu thông tin thành công")
                        }
                    }
                }
            }
        }
    }
    
    func fetchProfileData(withToken token: String) -> Observable<Void> {
        guard let userID = userID else { return Observable.empty() }

        let baseUrl = "https://firestore.googleapis.com/v1/projects/movieapp-74975/databases/(default)/documents/users"
        let profileUrl = "\(baseUrl)/\(userID)"

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        return Observable.create { observer in
            // Gửi request GET với Alamofire
            AF.request(profileUrl, method: .get, headers: headers).validate().responseDecodable(of: Profile2.self) { response in
                switch response.result {
                case .success(let profile):
                    print(profile.fields)

                    let fields = profile.fields
                    self.tfName.text = fields.name.stringValue
                    self.tfDOB.text = fields.dob.stringValue
//                    self.tfName.text = profile.name
//                    self.tfDOB.text = profile.dob

                    AF.request(fields.profileImageUrl.stringValue).responseData { imageResponse in
                        if let imageData = imageResponse.data {
                            self.imageView.image = UIImage(data: imageData)
                        }
                    }
//                    let nsurl = NSURL(string: profile.profileImageUrl ?? "123")!
//                    let request = URLRequest(url: nsurl as URL)
//                    AF.request(request).responseData {
//                        imageReponse in
//                        if let imageData = imageReponse.data {
//                            self.imageView.image = UIImage(data: imageData)
//                        }
//                    }

                    observer.onNext(())
                    observer.onCompleted()

                case .failure(let error):
                    observer.onError(error)
                    print(String(describing: error))
                    print("Lỗi lấy dữ liệu profile: \(error.localizedDescription)")
                }
            }
            return Disposables.create()
        }
    }

   
//    func fetchProfileData2(withToken token : String) {
//        guard let userID = userID else { return }
//        let userDoc = db.collection("users").document(userID)
//        userDoc.getDocument { document, error in
//            if let document = document, document.exists {
//                print(document)
//                let data = document.data()
//                print(data ?? "1234")
//                let name = data?["name"] as? String ?? ""
//                let dob = data?["dob"] as? String ?? ""
//                let profileImageUrl = data?["profileImageUrl"] as? String ?? ""
//
//                self.tfName.text = name
//                self.tfDOB.text = dob
//
//                if let url = URL(string: profileImageUrl) {
//                    AF.request(url).responseData { response in
//                        if let imageData = response.data {
//                            self.imageView.image = UIImage(data: imageData)
//                        }
//                    }
//                }
//            } else {
//                print("Không tìm thấy dữ liệu profile")
//            }
//        }
//    }
    
}
