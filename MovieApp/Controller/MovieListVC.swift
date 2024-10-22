//
//  MovieListVC.swift
//  MovieApp
//
//  Created by Developer 1 on 09/09/2024.
//

//import UIKit
//import Alamofire
//
//// Khai báo protocol, thiết lập delegate
//protocol MovieDetailDelegate: AnyObject {
//    // Hàm này đc gọi khi đánh dấu favorite
//    func didMarkAsFavorite(movie: Result, isFavorite: Bool)
//}
//
//class MovieListVC: UIViewController, MovieDetailDelegate {
//
//    @IBOutlet weak var mTable: UITableView!
//    var dataList = [Result]()
//    var selectedItem: Result?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("Screen 1: View Did load")
//
//        customNavigationBar()
//
//        mTable.dataSource = self
//        mTable.delegate = self
//        mTable.register(UINib(nibName: "MovieItemCell", bundle: nil), forCellReuseIdentifier: "cell")
//        //self.navigationController?.isNavigationBarHidden = false
//        fetchMovies()
//    }
//    @objc func tap() {
//            print("taped")
//        let vc = ProfileVC(nibName: "ProfileVC", bundle: nil)
//        navigationController?.pushViewController(vc, animated: true)
//        }
//
//    override func viewWillAppear(_ animated: Bool) {
//           print("Screen 1: View Will Appear")
//       }
//
//       override func viewDidAppear(_ animated: Bool) {
//           print("Screen 1: View Did Appear")
//       }
//
//       override func viewWillDisappear(_ animated: Bool) {
//           print("Screen 1: View Will DisAppear")
//       }
//
//       override func viewDidDisappear(_ animated: Bool) {
//           print("Screen 1: View Did DisAppear")
//       }
//    func customNavigationBar(){
//        //title = "The Movie"
//        navigationItem.title = "The Movies"
//        self.navigationController?.navigationBar.barTintColor = .cyan
//        //self.navigationController?.navigationBar.backgroundColor = .cyan
//
//        let profileItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tap))
//        navigationItem.rightBarButtonItem = profileItem
//    }
//
//
//    func fetchMovies() {
//        // URL gốc (không cần tham số trực tiếp trong URL nữa)
//        let baseURL = "https://api.themoviedb.org/3/movie/upcoming"
//
//        // Tham số query (parameters) cần truyền vào URL
//        let parameters: [String: Any] = [
//            "api_key": "c7f7d1dc5a6aa58fd2f3602748ad9c64",
//            "language": "en-US",
//            "page": 1
//        ]
//
//        // Header nếu cần
//        let headers: HTTPHeaders = [
//            "Authorization": "Bearer your_access_token_here",  // Đặt token nếu cần
//            "Accept": "application/json"
//        ]
//
//        // Gửi request với Alamofire (có tham số và header)
//        AF.request(baseURL, method: .get, parameters: parameters, headers: headers).validate().responseData { response in
//            switch response.result {
//            case .success(let data):
//                do {
//                    // Giải mã JSON trả về
//                    let result = try JSONDecoder().decode(MovieResult.self, from: data)
//                    DispatchQueue.main.async {
//                        // Cập nhật phim yêu thích từ UserDefaults
//                        let favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
//
//                        // Cập nhật trạng thái yêu thích của từng phim
//                        self.dataList = result.results.map { movie in
//                            var updatedMovie = movie
//                            updatedMovie.isFavorite = favoriteMovies.contains(movie.id)
//                            return updatedMovie
//                        }
//
//                        self.mTable.reloadData()
//                    }
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//            case .failure(let error):
//                print("Error fetching movies: \(error)")
//            }
//        }
//    }
//
//    // Delegate method để gọi khi thay đội trạng thái yêu thích
//    func didMarkAsFavorite(movie: Result, isFavorite: Bool) {
//        // Tìm vị trí phim trong datalist theo id trùng với movie.id
//        if let index = dataList.firstIndex(where: { $0.id == movie.id }) {
//            //cập nhật trạng thái yêuthichs
//            dataList[index].isFavorite = isFavorite
//            //Cập nhật row có vị trí index
//            mTable.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
//
//            // Cập nhật trạng thái yêu thích trong UserDefaults
//            updateFavoriteMoviesInUserDefaults(movieID: movie.id, isFavorite: isFavorite)
//        }
//    }
//
//    // Cập nhật phim yêu thích vào UserDefault
//    func updateFavoriteMoviesInUserDefaults(movieID: Int, isFavorite: Bool) {
//        // Lấy danh sách phim yêu thích- là 1 mảng
//        var favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
//        // Nếu phim được đánh dấu yêu thích, kiểm tra trong mảng có movieID không, chưa có thì add vào bằng append, nếu bỏ dấu thích thì xoá băngf removeAll theo movieID
//        if isFavorite {
//            if !favoriteMovies.contains(movieID) {
//                favoriteMovies.append(movieID)
//            }
//        } else {
//            favoriteMovies.removeAll { $0 == movieID }
//        }
//        // Lưu và cập nhật và UserDefault với khoá là favoriteMovies
//        UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
//    }
//}
//
//extension MovieListVC: UITableViewDataSource, UITableViewDelegate {
//    // Số dòng của table
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataList.count
//    }
//
//    // Set chiều cao của row
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200
//    }
//
//    // Truyền dữ liệu vào cell
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MovieItemCell
//        let movieData = dataList[indexPath.row]
//        cell.onBind(data: movieData)
//        return cell
//    }
//
//    // Chọn phim để xem chi tiết
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        selectedItem = dataList[indexPath.row]
//
//        let detailVC = MovieDetailVC(nibName: "MovieDetailVC", bundle: nil)
//        detailVC.movie = selectedItem // Truyền data của phim đc chọn
//        detailVC.isFavorite = selectedItem?.isFavorite ?? false // Truyền trạng thái yêu thích
//        detailVC.delegate = self   // Gán delegate là MovieListVC
//
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//}
//import UIKit
//import RxSwift
//import RxCocoa
//import RxAlamofire
//import FirebaseAuth
//
//protocol MovieDetailDelegate: AnyObject {
//    func didMarkAsFavorite(movie: Result, isFavorite: Bool)
//}
//
//class MovieListVC: UIViewController, UITableViewDelegate, MovieDetailDelegate {
//
//    @IBOutlet weak var mTable: UITableView!
//    var dataList = BehaviorRelay<[Result]>(value: []) // Relay để lưu danh sách phim
//    var selectedItem = PublishSubject<Result>() // Subject để theo dõi phim được chọn
//    private let disposeBag = DisposeBag()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("Screen 1: View Did load")
//
//        customNavigationBar()
//
//        mTable.register(UINib(nibName: "MovieItemCell", bundle: nil), forCellReuseIdentifier: "cell")
//        mTable.delegate = self // Đặt delegate cho tableView
//
//        bindTableView() // Bắt đầu bind tableView với dữ liệu
//        fetchMovies() // Tải danh sách phim
//    }
//
//    // Điều chỉnh thanh navigation bar
//    func customNavigationBar() {
//        navigationItem.title = "The Movies"
//        self.navigationController?.navigationBar.barTintColor = .cyan
//
//        let profileItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tap))
//        navigationItem.rightBarButtonItem = profileItem
//    }
//
//    @objc func tap() {
//        do {
//            print("logout")
////            UserDefaults.standard.removeObject(forKey: "userID")
////            UserDefaults.standard.removeObject(forKey: "idToken")
////            print("User logged out.")
////            try Auth.auth().signOut()  // Thực hiện logout
////            print("Logged out successfully")
////
////            // Điều hướng về màn hình đăng nhập (hoặc màn hình chính)
////            let loginVC = LoginVC()  // Thay thế bằng màn hình login của bạn
////            let navController = UINavigationController(rootViewController: loginVC)
////
////            // Lấy windowScene hiện tại
////            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
////               let sceneDelegate = windowScene.delegate as? SceneDelegate,
////               let window = sceneDelegate.window {
////
////                // Thiết lập navigation controller mới cho root view controller
////                window.rootViewController = navController
////                window.makeKeyAndVisible()
////            }
////
////        } catch let signOutError as NSError {
////            print("Error signing out: %@", signOutError)
//        }
//    }
//
//    // Bind dữ liệu vào TableView
//    func bindTableView() {
//        // Bind dataList vào tableView
//        dataList.bind(to: mTable.rx.items(cellIdentifier: "cell", cellType: MovieItemCell.self)) { index, movie, cell in
//            cell.onBind(data: movie)
//        }
//        .disposed(by: disposeBag)
//
//        // Xử lý sự kiện chọn phim
//        mTable.rx.modelSelected(Result.self)
//            .subscribe(onNext: { [weak self] movie in
//                self?.navigateToMovieDetail(movie: movie)
//                // Đảm bảo không có màu sắc nào thay đổi khi chọn ô
//                if let indexPath = self?.mTable.indexPathForSelectedRow {
//                    self?.mTable.deselectRow(at: indexPath, animated: false) // Bỏ chọn ô ngay lập tức
//                }
//            })
//            .disposed(by: disposeBag)
//    }
//
//    // Tải danh sách phim từ API
//    func fetchMovies() {
//        let baseURL = "https://api.themoviedb.org/3/movie/upcoming"
//        let parameters: [String: Any] = [
//            "api_key": "c7f7d1dc5a6aa58fd2f3602748ad9c64",
//            "language": "en-US",
//            "page": 1
//        ]
//
//        RxAlamofire
//            .requestData(.get, baseURL, parameters: parameters)
//            .subscribe(onNext: { [weak self] response, data in
//                do {
//                    let result = try JSONDecoder().decode(MovieResult.self, from: data)
//                    DispatchQueue.main.async {
//                        let favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
//                        let updatedDataList = result.results.map { movie in
//                            var updatedMovie = movie
//                            updatedMovie.isFavorite = favoriteMovies.contains(movie.id)
//                            return updatedMovie
//                        }
//                        self?.dataList.accept(updatedDataList) // Cập nhật danh sách phim
//                    }
//                } catch {
//                    print("Error decoding JSON: \(error)")
//                }
//            }, onError: { error in
//                print("Error fetching movies: \(error)")
//            })
//            .disposed(by: disposeBag)
//    }
//
//    // Điều hướng đến màn hình chi tiết phim
//    func navigateToMovieDetail(movie: Result) {
//        let detailVC = MovieDetailVC(nibName: "MovieDetailVC", bundle: nil)
//        detailVC.movie = movie
//        detailVC.isFavorite.accept(movie.isFavorite)  // Sử dụng accept để gán giá trị vào BehaviorRelay
//        detailVC.delegate = self //Gán delegate cho MovieListVC
//
//        navigationController?.pushViewController(detailVC, animated: true)
//    }
//
//    // Delegate method nhận sự thay đổi từ MovieDetailVC
//    func didMarkAsFavorite(movie: Result, isFavorite: Bool) {
//        updateFavoriteStatus(movie: movie, isFavorite: isFavorite)
//    }
//
//    // Cập nhật trạng thái yêu thích của phim
//    func updateFavoriteStatus(movie: Result, isFavorite: Bool) {
//        var movies = dataList.value
//        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
//            movies[index].isFavorite = isFavorite
//            dataList.accept(movies) // Cập nhật danh sách phim
//            updateFavoriteMoviesInUserDefaults(movieID: movie.id, isFavorite: isFavorite)
//        }
//    }
//
//    // Cập nhật trạng thái yêu thích vào UserDefaults
//    func updateFavoriteMoviesInUserDefaults(movieID: Int, isFavorite: Bool) {
//        var favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
//        if isFavorite {
//            if !favoriteMovies.contains(movieID) {
//                favoriteMovies.append(movieID)
//            }
//        } else {
//            favoriteMovies.removeAll { $0 == movieID }
//        }
//        UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
//    }
//
//    // Điều chỉnh chiều cao của cell
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 200 // Điều chỉnh chiều cao cell theo ý muốn
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        print("Screen 1: View Will Appear")
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        print("Screen 1: View Did Appear")
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        print("Screen 1: View Will DisAppear")
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        print("Screen 1: View Did DisAppear")
//    }
//}

import UIKit
import RxSwift
import RxCocoa
import RxAlamofire

protocol MovieDetailDelegate: AnyObject {
    func didMarkAsFavorite(movie: Result, isFavorite: Bool)
}
class MovieListVC: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var mTable: UITableView!
    private let viewModel = MovieListViewModel() // Khởi tạo ViewModel
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Screen 1: View Did load")

        customNavigationBar()

        mTable.register(UINib(nibName: "MovieItemCell", bundle: nil), forCellReuseIdentifier: "cell")
        mTable.delegate = self

        bindTableView()
        viewModel.fetchMovies() // Tải danh sách phim thông qua ViewModel
    }

    // Điều chỉnh thanh navigation bar
    func customNavigationBar() {
        navigationItem.title = "The Movies"
        self.navigationController?.navigationBar.barTintColor = .cyan

        let profileItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(tap))
        navigationItem.rightBarButtonItem = profileItem
    }

    @objc func tap() {
        // Xử lý logout
    }

    // Bind dữ liệu từ ViewModel vào TableView
    func bindTableView() {
        // Bind dataList từ ViewModel vào tableView
        viewModel.dataList.bind(to: mTable.rx.items(cellIdentifier: "cell", cellType: MovieItemCell.self)) { index, movie, cell in
            cell.onBind(data: movie)
        }
        .disposed(by: disposeBag)

        // Xử lý sự kiện chọn phim
        mTable.rx.modelSelected(Result.self)
            .subscribe(onNext: { [weak self] movie in
                self?.navigateToMovieDetail(movie: movie)
                if let indexPath = self?.mTable.indexPathForSelectedRow {
                    self?.mTable.deselectRow(at: indexPath, animated: false)
                }
            })
            .disposed(by: disposeBag)
    }

    // Điều hướng đến màn hình chi tiết phim
    func navigateToMovieDetail(movie: Result) {
        let detailVC = MovieDetailVC(nibName: "MovieDetailVC", bundle: nil)
        detailVC.movie = movie
        detailVC.isFavorite.accept(movie.isFavorite)
        detailVC.delegate = self // Gán delegate cho MovieListVC
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Điều chỉnh chiều cao của cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension MovieListVC: MovieDetailDelegate {
    func didMarkAsFavorite(movie: Result, isFavorite: Bool) {
        viewModel.updateFavoriteStatus(movie: movie, isFavorite: isFavorite)
    }
}
