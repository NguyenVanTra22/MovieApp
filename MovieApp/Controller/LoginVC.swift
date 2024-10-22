//
//  LoginVC.swift
//  MovieApp
//
//  Created by Developer 1 on 06/09/2024.
//

//import UIKit
//import Alamofire
//
//class LoginVC: UIViewController {
//
//    @IBOutlet weak var tfEmail: UITextField!
//    @IBOutlet weak var tfPassword: UITextField!
//
//    let firebaseAPIKey = "AIzaSyBym4axLcYf5t41M2I3Qd3UV1q_CJ847R8"  // Thay bằng API key từ Firebase console
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Thêm gesture tap để tắt bàn phím
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//        view.addGestureRecognizer(tapGesture)
//    }
//    @objc func hideKeyboard() {
//        view.endEditing(true)  // Tắt bàn phím
//    }
//
//    @IBAction func tapOnLogin(_ sender: Any) {
//        view.endEditing(true)
//        // Validator thông tin đầu vào
//        guard let email = tfEmail.text, !email.isEmpty,
//              let password = tfPassword.text, !password.isEmpty else {
//            print("Tài khoản hoặc mật khẩu không đúng")
//            return
//        }
//
//        // Firebase Auth REST API URL để xác thực qua Email/Password
//        let loginUrl = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(firebaseAPIKey)"
//
//        // Request body (thông tin đăng nhập)
//        let parameters: [String: Any] = [
//            "email": email,
//            "password": password,
//            "returnSecureToken": true
//        ]
//
//        // Gửi request với Alamofire
//        AF.request(loginUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
//            .validate()
//            .responseJSON { response in
//                switch response.result {
//                case .success(let data):
//                    if let json = data as? [String: Any], let idToken = json["idToken"] as? String {
//                        print("Đăng nhập thành công với token: \(idToken)")
//                        // Xử lý token ở đây hoặc tiếp tục quá trình đăng nhập
//
//                        // Chuyển sang màn hình danh sách phim
//                        let movieListVC = TabBarController()
//                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
//                        sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: movieListVC)
//                    }
//                case .failure(let error):
//                    print("Đăng nhập thất bại: \(error.localizedDescription)")
//                }
//            }
//
//    }
//    @IBAction func tapOnForgot(_ sender: Any) {
//    }
//
//    @IBAction func tapOnRegister(_ sender: Any) {
//        view.endEditing(true)
//        let vc = RegisterVC(nibName: "RegisterVC", bundle: nil)
//        navigationController?.pushViewController(vc, animated: true)
//    }
//}
import UIKit
import Alamofire
import RxSwift
import RxCocoa
import FirebaseAuth

class LoginVC: UIViewController {

    @IBOutlet weak var tfEmail: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    let firebaseAPIKey = "AIzaSyBym4axLcYf5t41M2I3Qd3UV1q_CJ847R8"
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Thêm gesture tap để tắt bàn phím
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setupBindings()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // RxSwift binding logic
    func setupBindings() {
        let emailObservable = tfEmail.rx.text.orEmpty.asObservable()
        let passwordObservable = tfPassword.rx.text.orEmpty.asObservable()
        // Kết hợp 2 observe email, password, xử lý nhiều đầu vào 1 lúc
        Observable.combineLatest(emailObservable, passwordObservable)
        //map để kiểm tra rỗng, trả về true/false
            .map { email, password in
                return !email.isEmpty && !password.isEmpty
            }
        // kết quả từ map đẩy vào isEnabled để làm điều kiện cho nút login hoạt động
            .bind(to: loginButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
        // lấy email, pass mới nhất tù Observable
            .withLatestFrom(Observable.combineLatest(emailObservable, passwordObservable))
        // trả về Obsevable cho đăng nhập, thay thế mọi yêu cầu đăng nhập trước đó nếu bấm nút login liên tục, giảm tải API request liên tục
            .flatMapLatest { [weak self] email, password -> Observable<[String: Any]> in
                guard let self = self else { return Observable.empty() }
                return self.login(email: email, password: password)
            }
        // lắng nghe và xử lý kết quả khi Observale trả dữ liệu login về
            .subscribe(onNext: { [weak self] json in
                if let idToken = json["idToken"] as? String {
                    print("Đăng nhập thành công với token: \(idToken)")
                    self?.navigateToMovieList()
                }
            }, onError: { error in
                print("Đăng nhập thất bại: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
        
        // Xử lý khi nhấn nút Register
        registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigateToRegister()
            })
            .disposed(by: disposeBag)
        
        // Xử lý khi nhấn nút Forgot Password
        forgotPasswordButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.navigateToForgotPassword()
            })
            .disposed(by: disposeBag)
    }
    
    
    func login(email: String, password: String) -> Observable<[String: Any]> {
        let loginUrl = "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=\(firebaseAPIKey)"
        let parameters: [String: Any] = [
            "email": email,
            "password": password,
            "returnSecureToken": true
        ]
        // Tạo 1 Observable tuỳ chỉnh, bên trong closure xử lý bất đồng bộ API
        return Observable.create { observer in
            AF.request(loginUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default)
                .validate()
                .responseJSON { response in
                    switch response.result {
                        // Thành công thì xử lý dữ liệu từ server thành json
                    case .success(let data):
                        //Kiểm tra có đúng là json không
                        if let json = data as? [String: Any] {
                            // Hợp lệ thì phát json tới người dùng
                            observer.onNext(json)
                        } else {
                            // Phát ra lỗi với dữ liệu json trả về
                            observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid data"]))
                        }
                    case .failure(let error):
                        //lỗi xảy ra trong quá trình yêu cầu HTTP, lỗi đó sẽ được phát
                        observer.onError(error)
                    }
                    //Sau khi xử lý xong (dù thành công hay thất bại), observer.onCompleted() sẽ được gọi để báo hiệu rằng Observable đã hoàn thành công việc của nó.
                    observer.onCompleted()
                }
            return Disposables.create()
        }
    }
    
    // Chuyển tới màn hình danh sách phim sau khi đăng nhập thành công
    func navigateToMovieList() {
        let movieListVC = ProfileViewController()
        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
        sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: movieListVC)
    }
    
    // Chuyển tới màn hình đăng ký
    func navigateToRegister() {
        let vc = RegisterVC(nibName: "RegisterVC", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Chuyển tới màn hình quên mật khẩu
    func navigateToForgotPassword() {
        // Logic điều hướng tới Forgot Password VC
        print("Chuyển tới màn hình quên mật khẩu")
    }
}
