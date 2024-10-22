//
//  RegisterVC.swift
//  MovieApp
//
//  Created by Developer 1 on 06/09/2024.
//

//import UIKit
//import FirebaseAuth
//import Alamofire
//
//class RegisterVC: UIViewController {
//
//    @IBOutlet weak var tfEmail: UITextField!
//    @IBOutlet weak var tfPass: UITextField!
//    @IBOutlet weak var tfName: UITextField!
//
//    @IBOutlet weak var datePicker: UIDatePicker!
//
//    let firebaseAPIKey = "AIzaSyBym4axLcYf5t41M2I3Qd3UV1q_CJ847R8"  // Thay bằng API Key từ Firebase Console
//    let projectID = "movieapp-74975"    // Thay bằng Project ID từ Firebase Console
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        datePicker.datePickerMode = .date
//        datePicker.maximumDate = Date()
//
//        // Thêm gesture tap để tắt bàn phím
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(tapGesture)
//    }
//
//    @objc func hideKeyboard() {
//        view.endEditing(true)  // Tắt bàn phím
//    }
//
//    @IBAction func tapOnRegisterVC(_ sender: Any) {
//        view.endEditing(true)
//
//        // Kiểm tra tính hợp lệ của thông tin người dùng
//        guard let email = tfEmail.text, !email.isEmpty,
//              let password = tfPass.text, !password.isEmpty,
//              let name = tfName.text, !name.isEmpty else {
//            print("Thông tin tài khoản không hợp lệ")
//            return
//        }
//
//        // Firebase Auth tạo tài khoản người dùng
//        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//            if let error = error {
//                print("Error creating user: \(error.localizedDescription)")
//            } else if let user = authResult?.user {
//                print("Đăng ký thành công. User: \(user.email ?? "No Email")")
//
//                // Lấy ngày sinh từ DatePicker
//                let dateOfBirth = self.datePicker.date
//
//                // Lấy ID Token để xác thực yêu cầu tới Firestore REST API
//                user.getIDToken(completion: { (idToken, error) in
//                    if let error = error {
//                        print("Error getting ID Token: \(error.localizedDescription)")
//                        return
//                    }
//
//                    if let idToken = idToken {
//                        // Sử dụng Alamofire để lưu thông tin người dùng vào Firestore
//                        self.saveUserToFirestore(userID: user.uid, name: name, email: email, dateOfBirth: dateOfBirth, idToken: idToken)
//                    }
//                })
//            }
//        }
//    }
//
//    // Hàm lưu thông tin người dùng vào Firestore sử dụng Alamofire
//    func saveUserToFirestore(userID: String, name: String, email: String, dateOfBirth: Date, idToken: String) {
//        // Định dạng ngày sinh thành chuỗi
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "dd/MM/yyyy"
//        let dateOfBirthString = dateFormatter.string(from: dateOfBirth)
//
//        // Endpoint của Firestore REST API
//        let url = "https://firestore.googleapis.com/v1/projects/\(projectID)/databases/(default)/documents/users/\(userID)"
//
//        // Cấu trúc dữ liệu theo yêu cầu của Firestore REST API
//        let parameters: [String: Any] = [
//            "fields": [
//                "name": ["stringValue": name],
//                "email": ["stringValue": email],
//                "dateOfBirth": ["stringValue": dateOfBirthString]
//            ]
//        ]
//
//        // Header với ID Token để xác thực
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer \(idToken)"
//        ]
//
//        // Gửi yêu cầu POST tới Firestore REST API
//        AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
//            .validate(statusCode: 200..<300)
//            .responseJSON { response in
//                switch response.result {
//                case .success:
//                    print("User saved to Firestore successfully")
//                    // Chuyển tới màn hình tiếp theo nếu cần
//                case .failure(let error):
//                    print("Error saving user to Firestore: \(error.localizedDescription)")
//                }
//            }
//    }
//}
import UIKit
import FirebaseAuth
import Alamofire
import RxSwift
import RxCocoa

class RegisterVC: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPass: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var registerButton: UIButton!
    
    let disposeBag = DisposeBag()
    
    let firebaseAPIKey = "AIzaSyBym4axLcYf5t41M2I3Qd3UV1q_CJ847R8"  // Thay bằng API Key từ Firebase Console
    let projectID = "movieapp-74975"    // Thay bằng Project ID từ Firebase Console

    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        // Ẩn bàn phím khi tap ngoài TextField
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        bindUI()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Binding các sự kiện UI với RxSwift và RxCocoa
    func bindUI() {
        // Tạo Observables từ các UITextField
        let emailObservable = tfEmail.rx.text.orEmpty.asObservable()
        let passwordObservable = tfPass.rx.text.orEmpty.asObservable()
        let nameObservable = tfName.rx.text.orEmpty.asObservable()
        
        // Kết hợp và kiểm tra các giá trị hợp lệ
        let isFormValid = Observable.combineLatest(emailObservable, passwordObservable, nameObservable) { email, password, name in
            return !email.isEmpty && !password.isEmpty && !name.isEmpty
        }
        
        // Ràng buộc giá trị hợp lệ với nút đăng ký
        isFormValid
            .bind(to: registerButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        // Xử lý sự kiện khi nhấn nút đăng ký
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.registerUser()
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Đăng ký người dùng
    func registerUser() {
        guard let email = tfEmail.text, let password = tfPass.text, let name = tfName.text else {
            print("Thông tin tài khoản không hợp lệ")
            return
        }

        // Firebase Auth tạo tài khoản người dùng (sử dụng Observable)
        createUser(email: email, password: password)
            //Nhận user từ create
            .flatMap { user -> Observable<String?> in
                if let user = user {
                    //User không nil thì thấy Token, đặt token trong create
                    return Observable.create { observer in
                        // Lấy đc token thì đẩy vào onNext, không thì vào Error
                        user.getIDToken { idToken, error in
                            if let error = error {
                                observer.onError(error)
                            } else {
                                observer.onNext(idToken)
                                observer.onCompleted()
                            }
                        }
                        return Disposables.create()
                    }
                } else {
                    // User trả về là nil hặc lỗi thì trả về cái này
                    return Observable.just(nil)
                }
            }
            // Lưu thông tin vào Firebase, Trar về Observable: true là lưu thành công
            .flatMap { idToken -> Observable<Bool> in
                // Lấy idToken từ bên trên
                guard let idToken = idToken else {
                    return Observable.just(false)
                }
                
                // Lấy ngày sinh từ DatePicker
                let dateOfBirth = self.datePicker.date
                
                // Lưu thông tin người dùng vào Firestore qua API
                return self.saveUserToFirestore(userID: Auth.auth().currentUser?.uid ?? "", name: name, email: email, dateOfBirth: dateOfBirth, idToken: idToken)
            }
        //subscribe để nhận kết quả từ bên trên là true hay false với onNext; onError để trả về lỗi
            .subscribe(onNext: { success in
                if success {
                    print("Lưu người dùng thành công")
                    // Điều hướng hoặc xử lý sau khi đăng ký thành công
                } else {
                    print("Lỗi trong quá trình lưu thông tin người dùng")
                }
            }, onError: { error in
                print("Lỗi: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Hàm tạo người dùng Firebase Auth sử dụng RxSwift
    func createUser(email: String, password: String) -> Observable<User?> {
        return Observable.create { observer in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onNext(authResult?.user)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }

    // MARK: - Hàm lưu thông tin người dùng vào Firestore
    func saveUserToFirestore(userID: String, name: String, email: String, dateOfBirth: Date, idToken: String) -> Observable<Bool> {
        return Observable.create { observer in
            // Định dạng ngày sinh thành chuỗi
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateOfBirthString = dateFormatter.string(from: dateOfBirth)
            
            // Endpoint của Firestore REST API
            let url = "https://firestore.googleapis.com/v1/projects/\(self.projectID)/databases/(default)/documents/users/\(userID)"
            
            // Cấu trúc dữ liệu theo yêu cầu của Firestore REST API
            let parameters: [String: Any] = [
                "fields": [
                    "name": ["stringValue": name],
                    "email": ["stringValue": email],
                    "dateOfBirth": ["stringValue": dateOfBirthString]
                ]
            ]
            
            // Header với ID Token để xác thực
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken)"
            ]
            
            // Gửi yêu cầu POST tới Firestore REST API qua Alamofire
            AF.request(url, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        observer.onNext(true)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create()
        }
    }
}
