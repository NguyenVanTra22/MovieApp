//
//  ProfileController.swift
//  MovieApp
//
//  Created by Developer 1 on 03/10/2024.
//

import UIKit
import RxSwift
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Alamofire

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var profileView: ProfileView! // View
    let disposeBag = DisposeBag()
    var userID: String?
    
    // Khởi tạo Firestore và Storage
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile View Did Load")
        
        // Khởi tạo profileView từ XIB
        profileView = ProfileView()
        view.addSubview(profileView)
        profileView.frame = view.bounds
        profileView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Gesture để tắt bàn phím khi chạm vào nơi khác
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        // Lấy userID từ Firebase Auth
        if let currentUserID = Auth.auth().currentUser?.uid {
            userID = currentUserID
            print("User ID: \(userID ?? "")")
        }

        // Fetch profile data nếu có userID
        if userID != nil {
            fetchProfileData()
        }

        // Thiết lập sự kiện cho nút chọn ảnh
        profileView.selectImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectImage()
            })
            .disposed(by: disposeBag)

        // Thiết lập sự kiện cho nút lưu
        profileView.saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveProfile()
            })
            .disposed(by: disposeBag)
    }

    // Phương thức để tắt bàn phím
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // Fetch dữ liệu profile từ Firestore
    func fetchProfileData() {
        getIDToken()
            .flatMap { token -> Observable<Profile> in // Xác định kiểu trả về của closure
                return self.fetchProfileDataformFirebase(withToken: token)
            }
            .subscribe(
                onNext: { [weak self] profile in
                    guard let self = self else { return }
                    self.profileView.displayProfile(profile: profile)

                    // Tải ảnh profile từ URL
                    AF.request(profile.profileImageUrl).responseData { response in
                        if let data = response.data, let image = UIImage(data: data) {
                            self.profileView.displayProfileImage(image)
                        }
                    }
                },
                onError: { error in
                    print("Lỗi khi tải dữ liệu profile: \(error)")
                }
            )
            .disposed(by: disposeBag)
    }

    // Chọn ảnh từ thư viện
    func selectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            profileView.displayProfileImage(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // Lưu profile vào Firestore và Firebase Storage
    func saveProfile() {
        guard let name = profileView.tfName.text,
              let dob = profileView.tfDOB.text,
              let image = profileView.imageView.image,
              let userID = userID else { return }

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            saveImageToStorage(userID: userID, imageData: imageData)
                .flatMap { url -> Observable<Void> in
                    self.saveProfileToFirestore(userID: userID, name: name, dob: dob, imageUrl: url)
                }
                .subscribe(onNext: {
                    print("Profile saved successfully")
                }, onError: { error in
                    print("Error saving profile: \(error)")
                })
                .disposed(by: disposeBag)
        }
    }

    // Hàm lấy ID Token từ Firebase Authentication
    func getIDToken() -> Observable<String> {
        return Observable.create { observer in
            Auth.auth().currentUser?.getIDToken { token, error in
                if let error = error {
                    observer.onError(error)
                } else if let token = token {
                    observer.onNext(token)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    // Hàm lưu ảnh vào Firebase Storage
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

    // Hàm lưu thông tin profile vào Firestore
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

    // Hàm lấy dữ liệu profile từ Firestore với token
    func fetchProfileDataformFirebase(withToken token: String) -> Observable<Profile> {
        guard let userID = userID else { return Observable.empty() }

        // Base URL và endpoint
        let baseUrl = "https://firestore.googleapis.com/v1/projects/movieapp-74975/databases/(default)/documents/users"
        let profileUrl = "\(baseUrl)/\(userID)"

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",  // Truyền token vào headers
            "Content-Type": "application/json"
        ]

        return Observable.create { observer in
            // Gửi request GET với Alamofire
            AF.request(profileUrl, method: .get, headers: headers).validate().responseJSON { response in
                switch response.result {
                case .success(let data):
                    // Xử lý dữ liệu JSON
                    if let json = data as? [String: Any],
                       let profile = Profile(json: json) {
                        // Truyền đối tượng Profile qua observer
                        observer.onNext(profile)
                        observer.onCompleted()
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                    print("Lỗi lấy dữ liệu profile: \(error.localizedDescription)")
                }
            }
            return Disposables.create()
        }
    }

}
