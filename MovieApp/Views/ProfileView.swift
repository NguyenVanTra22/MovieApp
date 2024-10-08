//
//  ProfileVC.swift
//  MovieApp
//
//  Created by Developer 1 on 19/09/2024.
//

//import UIKit
//import FirebaseFirestore
//import FirebaseStorage
//import FirebaseAuth
//import Alamofire
//
//class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var tfName: UITextField!
//    @IBOutlet weak var tfDOB: UITextField!
//
//    let db = Firestore.firestore()
//    let storage = Storage.storage().reference()
//    var userID: String?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Lấy user ID từ Firebase Auth khi người dùng đã đăng nhập
//        if let currentUserID = Auth.auth().currentUser?.uid {
//            userID = currentUserID
//            print(userID ?? "123user")
//        }
//
//        // Thêm gesture tap để tắt bàn phím
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(tapGesture)
//
//        // Lấy Firebase ID token và fetch dữ liệu
//        Auth.auth().currentUser?.getIDToken { token, error in
//            if let error = error {
//                print("Lỗi lấy token: \(error.localizedDescription)")
//                return
//            }
//            print(token ?? ".xxxxxxxx")
//            guard let token = token else {
//                print("Không lấy được token")
//                return
//            }
//
//            // Gọi hàm fetch dữ liệu profile với token
//            self.fetchProfileData(withToken: token)
//        }
//    }
//
//    @objc func hideKeyboard() {
//        view.endEditing(true)  // Tắt bàn phím
//    }
//
//    // MARK: - Chọn ảnh
//    @IBAction func selectImage(_ sender: Any) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImage = info[.originalImage] as? UIImage {
//            imageView.image = selectedImage
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    // MARK: - Lưu thông tin profile
//    @IBAction func saveProfile(_ sender: Any) {
//        guard let name = tfName.text, !name.isEmpty,
//              let dob = tfDOB.text, !dob.isEmpty,
//              let image = imageView.image,
//              let userID = userID else {
//            print("Thông tin chưa đầy đủ hoặc chưa xác định user ID")
//            return
//        }
//
//        // Lưu ảnh vào Firebase Storage
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            let imageRef = storage.child("profile_images/\(userID).jpg")
//            imageRef.putData(imageData, metadata: nil) { metadata, error in
//                guard error == nil else {
//                    print("Lỗi lưu ảnh: \(error!.localizedDescription)")
//                    return
//                }
//
//                // Lấy URL của ảnh từ Firebase Storage
//                imageRef.downloadURL { url, error in
//                    guard let url = url, error == nil else {
//                        print("Lỗi lấy URL ảnh: \(error!.localizedDescription)")
//                        return
//                    }
//
//                    // Lưu thông tin profile vào Firestore
//                    self.db.collection("users").document(userID).setData([
//                        "name": name,
//                        "dob": dob,
//                        "profileImageUrl": url.absoluteString
//                    ]) { error in
//                        if let error = error {
//                            print("Lỗi lưu thông tin: \(error.localizedDescription)")
//                        } else {
//                            print("Lưu thông tin thành công")
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: - Fetch dữ liệu profile với token
//    func fetchProfileData(withToken token: String) {
//        guard let userID = userID else { return }
//        print(userID)
//        // Base URL và endpoint
//        let baseUrl = "https://firestore.googleapis.com/v1/projects/movieapp-74975/databases/(default)/documents/users"
//        let profileUrl = "\(baseUrl)/\(userID)"
//
//        // Parameters và headers cho request
//        let parameters: [String: Any] = [
//            "userID": userID
//        ]
//
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(token)",  // Truyền token vào headers
//            "Content-Type": "application/json"
//        ]
//
//        // Gửi request POST với Alamofire
//        AF.request(profileUrl, method: .get, headers: headers).validate().responseJSON { response in
//            switch response.result {
//            case .success(let data):
//                // Xử lý dữ liệu JSON
//                if let json = data as? [String: Any],
//                   let profile = Profile(json: json) {
//                    // Hiển thị thông tin profile
//                    self.tfName.text = profile.name
//                    self.tfDOB.text = profile.dob
//
//                    // Tải và hiển thị ảnh profile
//                    AF.request(profile.profileImageUrl).responseData { response in
//                        if let imageData = response.data {
//                            self.imageView.image = UIImage(data: imageData)
//                        }
//                    }
//                } else {
//                    print("Lỗi trong cấu trúc JSON: \(data)")
//                }
//            case .failure(let error):
//                print("Lỗi lấy dữ liệu profile: \(error.localizedDescription)")
//            }
//        }
//    }
//}


//import UIKit
//import FirebaseFirestore
//import FirebaseStorage
//import FirebaseAuth
//import Alamofire
//import RxSwift
//import RxCocoa
//
//class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var tfName: UITextField!
//    @IBOutlet weak var tfDOB: UITextField!
//
//    let db = Firestore.firestore()
//    let storage = Storage.storage().reference()
//    var userID: String?
//
//    let disposeBag = DisposeBag()  // Quản lý các subscription trong RxSwift
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Lấy user ID từ Firebase Auth khi người dùng đã đăng nhập
//        if let currentUserID = Auth.auth().currentUser?.uid {
//            userID = currentUserID
//            print(userID ?? "123user")
//        }
//
//        // Gesture tap để tắt bàn phím
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(tapGesture)
//
//        // Lấy Firebase ID token và fetch dữ liệu
//        getIDToken()
//            .flatMap { token -> Observable<Void> in
//                return self.fetchProfileData(withToken: token)
//            }
//            .subscribe()
//            .disposed(by: disposeBag)
//    }
//
//    @objc func hideKeyboard() {
//        view.endEditing(true)  // Tắt bàn phím
//    }
//
//    // MARK: - Chọn ảnh
//    @IBAction func selectImage(_ sender: Any) {
//        let imagePicker = UIImagePickerController()
//        imagePicker.delegate = self
//        imagePicker.sourceType = .photoLibrary
//        present(imagePicker, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let selectedImage = info[.originalImage] as? UIImage {
//            imageView.image = selectedImage
//        }
//        dismiss(animated: true, completion: nil)
//    }
//
//    // MARK: - Lưu thông tin profile
//    @IBAction func saveProfile(_ sender: Any) {
//        guard let name = tfName.text, !name.isEmpty,
//              let dob = tfDOB.text, !dob.isEmpty,
//              let image = imageView.image,
//              let userID = userID else {
//            print("Thông tin chưa đầy đủ hoặc chưa xác định user ID")
//            return
//        }
//
//        // Lưu ảnh vào Firebase Storage
//        if let imageData = image.jpegData(compressionQuality: 0.8) {
//            saveImageToStorage(imageData: imageData, userID: userID)
//                .flatMap { url -> Observable<Void> in
//                    return self.saveProfileToFirestore(name: name, dob: dob, imageUrl: url)
//                }
//                .subscribe(onNext: {
//                    print("Lưu thông tin thành công")
//                }, onError: { error in
//                    print("Lỗi lưu thông tin: \(error.localizedDescription)")
//                })
//                .disposed(by: disposeBag)
//        }
//    }
//
//    // MARK: - Firebase getIDToken chuyển thành Observable
//    func getIDToken() -> Observable<String> {
//        return Observable.create { observer in
//            Auth.auth().currentUser?.getIDToken { token, error in
//                if let error = error {
//                    observer.onError(error)
//                } else if let token = token {
//                    observer.onNext(token)
//                    observer.onCompleted()
//                }
//            }
//            return Disposables.create()
//        }
//    }
//
//    // MARK: - Lưu ảnh vào Firebase Storage và trả về URL
//    func saveImageToStorage(imageData: Data, userID: String) -> Observable<URL> {
//        return Observable.create { observer in
//            let imageRef = self.storage.child("profile_images/\(userID).jpg")
//            imageRef.putData(imageData, metadata: nil) { metadata, error in
//                guard error == nil else {
//                    observer.onError(error!)
//                    return
//                }
//
//                imageRef.downloadURL { url, error in
//                    if let error = error {
//                        observer.onError(error)
//                    } else if let url = url {
//                        observer.onNext(url)
//                        observer.onCompleted()
//                    }
//                }
//            }
//            return Disposables.create()
//        }
//    }
//
//    // MARK: - Lưu thông tin profile vào Firestore
//    func saveProfileToFirestore(name: String, dob: String, imageUrl: URL) -> Observable<Void> {
//        return Observable.create { observer in
//            guard let userID = self.userID else {
//                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không có userID"]))
//                return Disposables.create()
//            }
//
//            self.db.collection("users").document(userID).setData([
//                "name": name,
//                "dob": dob,
//                "profileImageUrl": imageUrl.absoluteString
//            ]) { error in
//                if let error = error {
//                    observer.onError(error)
//                } else {
//                    observer.onNext(())
//                    observer.onCompleted()
//                }
//            }
//            return Disposables.create()
//        }
//    }
//
//    // MARK: - Fetch dữ liệu profile với token
//    func fetchProfileData(withToken token: String) -> Observable<Void> {
//        guard let userID = userID else { return Observable.empty() }
//
//        // Base URL và endpoint
//        let baseUrl = "https://firestore.googleapis.com/v1/projects/movieapp-74975/databases/(default)/documents/users"
//        let profileUrl = "\(baseUrl)/\(userID)"
//
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(token)",  // Truyền token vào headers
//            "Content-Type": "application/json"
//        ]
//
//        return Observable.create { observer in
//            // Gửi request GET với Alamofire
//            AF.request(profileUrl, method: .get, headers: headers).validate().responseJSON { response in
//                switch response.result {
//                case .success(let data):
//                    // Xử lý dữ liệu JSON
//                    if let json = data as? [String: Any],
//                       let profile = Profile(json: json) {
//                        self.tfName.text = profile.name
//                        self.tfDOB.text = profile.dob
//
//                        // Tải và hiển thị ảnh profile
//                        AF.request(profile.profileImageUrl).responseData { response in
//                            if let imageData = response.data {
//                                self.imageView.image = UIImage(data: imageData)
//                            }
//                        }
//                    } else {
//                        print("Lỗi trong cấu trúc JSON: \(data)")
//                    }
//                    observer.onNext(())
//                    observer.onCompleted()
//                case .failure(let error):
//                    observer.onError(error)
//                    print("Lỗi lấy dữ liệu profile: \(error.localizedDescription)")
//                }
//            }
//            return Disposables.create()
//        }
//    }
//}
import UIKit

class ProfileView: UIView {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var tfDOB: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var viewContent: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("ProfileView", owner: self, options: nil)
        self.addSubview(viewContent)
        viewContent.frame = self.bounds
        viewContent.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func displayProfile(profile: Profile) {
        tfName.text = profile.name
        tfDOB.text = profile.dob
    }
    
    func displayProfileImage(_ image: UIImage) {
        imageView.image = image
    }
}
