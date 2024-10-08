//
//  ProfileController.swift
//  MovieApp
//
//  Created by Developer 1 on 03/10/2024.
//

import UIKit
import RxSwift
import FirebaseAuth
import Alamofire

class ProfileController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var profileView: ProfileView! // View
    let profileModel = ProfileModel() // Model
    let disposeBag = DisposeBag()
    var userID: String?
    
    
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
        print(userID ?? "123")
        // Fetch profile data
        if userID != nil {
            fetchProfileData()
        }

        // Thiết lập sự kiện cho nút chọn ảnh
        profileView.selectImageButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.selectImage()
            })
            .disposed(by: disposeBag)

        profileView.saveButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.saveProfile()
                print("tap on save")
            })
            .disposed(by: disposeBag)
    }

    // Phương thức để tắt bàn phím
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func fetchProfileData() {
        getIDToken()
            .flatMap { token -> Observable<Profile> in
                return self.profileModel.fetchProfileData(userID: self.userID!, token: token)
            }
            .subscribe(onNext: { [weak self] profile in
                guard let self = self else { return }
                self.profileView.displayProfile(profile: profile)

                // Tải ảnh profile từ URL
                AF.request(profile.profileImageUrl).responseData { response in
                    if let data = response.data, let image = UIImage(data: data) {
                        self.profileView.displayProfileImage(image)
                    }
                }
            }, onError: { error in
                print("Lỗi khi tải dữ liệu profile: \(error)")
            })
            .disposed(by: disposeBag)
    }

    // Hàm chọn ảnh từ thư viện
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

    // Lưu profile
    func saveProfile() {
        guard let name = profileView.tfName.text,
              let dob = profileView.tfDOB.text,
              let image = profileView.imageView.image,
              let userID = userID else { return }
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            profileModel.saveImageToStorage(userID: userID, imageData: imageData)
                .flatMap { url -> Observable<Void> in
                    self.profileModel.saveProfileToFirestore(userID: userID, name: name, dob: dob, imageUrl: url)
                }
                .subscribe(onNext: {
                    print("Profile saved successfully")
                }, onError: { error in
                    print("Error saving profile: \(error)")
                })
                .disposed(by: disposeBag)
        }
    }

    // ID Token
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
}
