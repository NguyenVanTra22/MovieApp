//
//  MovieDetailVC.swift
//  MovieApp
//
//  Created by Developer 1 on 09/09/2024.
//


//import UIKit
//import Foundation
//import Alamofire
//class ShareReferent {
//    static let shared = ShareReferent()
//
//    private var favoriteMovies = [Int: Bool]()  // Lưu trạng thái yêu thích theo ID phim
//
//    private init() {}
//    //phương thức này để lưu trạng thái yêu thích của phim
//    // key là movie.id và giá trị là trạng thái true/fall của isFavorite
//    func saveFavorite(movie: Result) {
//        favoriteMovies[movie.id] = movie.isFavorite
//    }
//
//
//    func isFavorite(movieID: Int) -> Bool {
//        return favoriteMovies[movieID] ?? false
//    }
//}
//
//class MovieDetailVC: UIViewController {
//
//    @IBOutlet weak var favoriteButton: UIButton!
//    @IBOutlet weak var imageDetail: UIImageView!
//    @IBOutlet weak var desDetail: UILabel!
//    @IBOutlet weak var nameDetail: UILabel!
//
//    var movie: Result?
//    var isFavorite: Bool = false
//    weak var delegate: MovieDetailDelegate?  // biến weak để tránh vòng tham chiếu, dùng để gán đối tượng bên ngoài
//    let shareReferent = ShareReferent.shared  // Sử dụng ShareReferent
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        print("Screen 2: View Did load")
//        nameDetail.text = movie?.title
//        desDetail.text = movie?.overview
//        navigationItem.title = "Movie Detail"
//
//        if let posterPath = movie?.posterPath {
//            let imageUrl = "https://image.tmdb.org/t/p/w500\(posterPath)"
//            AF.request(imageUrl).responseData { [weak self] response in  // Sử dụng weak self
//                guard let self = self else { return }  // Đảm bảo self vẫn tồn tại
//                switch response.result {
//                case .success(let data):
//                    DispatchQueue.main.async {
//                        self.imageDetail.image = UIImage(data: data)
//                    }
//                case .failure(let error):
//                    print("Error loading image: \(error)")
//                }
//            }
//        }
//
//
//        updateFavoriteButton()
//    }
//    override func viewWillAppear(_ animated: Bool) {
//           print("Screen 2: View Will Appear")
//       }
//
//       override func viewDidAppear(_ animated: Bool) {
//           print("Screen 2: View Did Appear")
//       }
//
//       override func viewWillDisappear(_ animated: Bool) {
//           print("Screen 2: View Will DisAppear")
//       }
//
//       override func viewDidDisappear(_ animated: Bool) {
//           print("Screen 2: View Did DisAppear")
//       }
//
//    func updateFavoriteButton() {
//        let imageName = isFavorite ? "star.fill" : "star"
//        let image = UIImage(systemName: imageName)
//        favoriteButton.setImage(image, for: .normal)
//        favoriteButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25), forImageIn: .normal)
//    }
//
//    @IBAction func favoriteButtonTapped(_ sender: Any) {
//        isFavorite.toggle()
//        updateFavoriteButton()
//
//        if let selectedMovie = movie {
//            // Gọi delegate để thông báo về sự thay đổi
//            delegate?.didMarkAsFavorite(movie: selectedMovie, isFavorite: isFavorite)
//
//            // Lưu trạng thái yêu thích vào ShareReferent
//            shareReferent.saveFavorite(movie: selectedMovie)
//        }
//    }
//}
import UIKit
import Alamofire
import RxSwift
import RxCocoa

class ShareReferent {
    static let shared = ShareReferent()

    private var favoriteMovies = [Int: Bool]()  // Lưu trạng thái yêu thích theo ID phim

    private init() {}
    
    // Phương thức này để lưu trạng thái yêu thích của phim
    func saveFavorite(movieID: Int, isFavorite: Bool) {
        favoriteMovies[movieID] = isFavorite
    }

    // Kiểm tra trạng thái yêu thích
    func isFavorite(movieID: Int) -> Bool {
        return favoriteMovies[movieID] ?? false
    }
}

class MovieDetailVC: UIViewController {

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var imageDetail: UIImageView!
    @IBOutlet weak var desDetail: UILabel!
    @IBOutlet weak var nameDetail: UILabel!

    var movie: Result?
    weak var delegate: MovieDetailDelegate?
    let shareReferent = ShareReferent.shared
    var isFavorite = BehaviorRelay<Bool>(value: false) // Sử dụng BehaviorRelay cho isFavorite
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Screen 2: View Did load")

        // Hiển thị thông tin phim
        nameDetail.text = movie?.title
        desDetail.text = movie?.overview
        navigationItem.title = "Movie Detail"

        // Tải hình ảnh phim
        loadMovieImage()
        updateFavoriteButton(isFavorite: isFavorite.value) // Cập nhật nút yêu thích theo trạng thái

        // Kiểm tra trạng thái yêu thích từ ShareReferent và cập nhật nút
        if let selectedMovie = movie {
            let isFavorite = shareReferent.isFavorite(movieID: selectedMovie.id)
        }
    }

    func loadMovieImage() {
        guard let posterPath = movie?.posterPath else { return }
        let imageUrl = "https://image.tmdb.org/t/p/w500\(posterPath)"
        
        // Tải ảnh từ URL
        AF.request(imageUrl).responseData { [weak self] response in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                DispatchQueue.main.async {
                    self.imageDetail.image = UIImage(data: data)
                }
            case .failure(let error):
                print("Error loading image: \(error)")
            }
        }
    }

    func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? "star.fill" : "star"
        let image = UIImage(systemName: imageName)
        favoriteButton.setImage(image, for: .normal)
        favoriteButton.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25), forImageIn: .normal)
    }

    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let selectedMovie = movie else { return }
        
        // Lấy trạng thái hiện tại
        let currentFavoriteStatus = shareReferent.isFavorite(movieID: selectedMovie.id)
        
        // Đảo trạng thái yêu thích
        let newFavoriteStatus = !currentFavoriteStatus
        
        // Cập nhật trạng thái yêu thích vào ShareReferent
        shareReferent.saveFavorite(movieID: selectedMovie.id, isFavorite: newFavoriteStatus)

        // Cập nhật UI nút yêu thích
        updateFavoriteButton(isFavorite: newFavoriteStatus)

        // Gọi delegate để thông báo về sự thay đổi
        delegate?.didMarkAsFavorite(movie: selectedMovie, isFavorite: newFavoriteStatus)
    }
}
