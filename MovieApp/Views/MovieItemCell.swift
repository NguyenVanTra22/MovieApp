//
//  MovieItemCell.swift
//  MovieApp
//
//  Created by Developer 1 on 09/09/2024.
//

//import UIKit
//
//class MovieItemCell: UITableViewCell {
//
//    @IBOutlet weak var favoriteImageView: UIImageView!
//    @IBOutlet weak var mImage: UIImageView!
//    @IBOutlet weak var txtDesc: UILabel!
//    @IBOutlet weak var txtName: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
//
//    func onBind(data: Result) {
//        //print("Binding movie data: \(data.title)")  // Kiểm tra dữ liệu được truyền vào
//        txtName.text = data.title
//        txtDesc.text = data.overview
//        let favoriteImage = data.isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
//        favoriteImageView.image = favoriteImage
//
//        // Kiểm tra URL hình ảnh
//        if let url = URL(string: "https://image.tmdb.org/t/p/w342/\(data.posterPath)") {
//            //print("Loading image from URL: \(url)")
//            mImage.image = nil
//            URLSession.shared.dataTask(with: url) { (data, response, error) in
//                if let data = data {
//                    DispatchQueue.main.async {
//                        self.mImage.image = UIImage(data: data)
//                    }
//                } else {
//                    print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
//                }
//            }.resume()
//        }
//    }
//
//}
import UIKit
import RxSwift
import RxCocoa

class MovieItemCell: UITableViewCell {
    
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var mImage: UIImageView!
    @IBOutlet weak var txtDesc: UILabel!
    @IBOutlet weak var txtName: UILabel!
    
    let disposeBag = DisposeBag() // Quản lý bộ nhớ của các Observable

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // Hàm bind dữ liệu sử dụng RxSwift
    func onBind(data: Result) {
        // Bind tên và mô tả của phim
        Observable.just(data.title)
            .bind(to: txtName.rx.text)
            .disposed(by: disposeBag)
        
        Observable.just(data.overview)
            .bind(to: txtDesc.rx.text)
            .disposed(by: disposeBag)
        
        // Bind trạng thái yêu thích và cập nhật hình ảnh yêu thích
        Observable.just(data.isFavorite)
            .map { isFavorite -> UIImage? in
                return isFavorite ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            }
            .bind(to: favoriteImageView.rx.image)
            .disposed(by: disposeBag)
        
        // Tải ảnh sử dụng RxSwift với URLSession
        if let url = URL(string: "https://image.tmdb.org/t/p/w342/\(data.posterPath)") {
            loadImage(from: url)
                .observe(on: MainScheduler.instance) // Đảm bảo UI được cập nhật trên Main Thread
                .subscribe(onNext: { [weak self] image in
                    self?.mImage.image = image
                }, onError: { error in
                    print("Failed to load image: \(error.localizedDescription)")
                })
                .disposed(by: disposeBag)
        }
    }
    
    // Tạo Observable để tải ảnh từ URL
    func loadImage(from url: URL) -> Observable<UIImage?> {
        return Observable.create { observer in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    observer.onError(error) // Trả về lỗi nếu có
                } else if let data = data, let image = UIImage(data: data) {
                    observer.onNext(image) // Trả về hình ảnh đã tải
                    observer.onCompleted() // Hoàn thành Observable
                } else {
                    observer.onNext(nil) // Trả về nil nếu không có dữ liệu ảnh
                    observer.onCompleted()
                }
            }
            task.resume()
            
            // Trả về Disposable để hủy task nếu cần
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
