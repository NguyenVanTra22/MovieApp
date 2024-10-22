//
//  MovieListViewModel.swift
//  MovieApp
//
//  Created by Developer 1 on 08/10/2024.
//

import Foundation
import RxCocoa
import RxSwift
import RxAlamofire

class MovieListViewModel {
    //Lưu trữ danh sách phim hiện tại và tự động thông báo cho các subscribers khi dữ liệu thay đổi.
    let dataList = BehaviorRelay<[Result]>(value: [])
    //PublishSubject không lưu trữ bất kỳ giá trị nào. Khi có một sự kiện được phát ra, nó sẽ gửi sự kiện đó đến các subscribers hiện tại.
    let selectedItem = PublishSubject<Result>()
    private let disposeBag = DisposeBag()

    func fetchMovies() {
        let baseURL = "https://api.themoviedb.org/3/movie/upcoming"
        let parameters: [String: Any] = [
            "api_key": "c7f7d1dc5a6aa58fd2f3602748ad9c64",
            "language": "en-US",
            "page": 1
        ]

        RxAlamofire
            .requestData(.get, baseURL, parameters: parameters)
            .subscribe(onNext: { [weak self] response, data in
                
                do {
                    let result = try JSONDecoder().decode(MovieResult.self, from: data)
                    DispatchQueue.main.async {
                        let favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
                        let updatedDataList = result.results.map { movie in
                            var updatedMovie = movie
                            updatedMovie.isFavorite = favoriteMovies.contains(movie.id)
                            return updatedMovie
                        }
                        self?.dataList.accept(updatedDataList) // Cập nhật danh sách phim
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }, onError: { error in
                print("Error fetching movies: \(error)")
            })
            .disposed(by: disposeBag)
    }

    // Cập nhật trạng thái yêu thích của phim
    func updateFavoriteStatus(movie: Result, isFavorite: Bool) {
        var movies = dataList.value
        if let index = movies.firstIndex(where: { $0.id == movie.id }) {
            movies[index].isFavorite = isFavorite
            dataList.accept(movies) // Cập nhật danh sách phim
            updateFavoriteMoviesInUserDefaults(movieID: movie.id, isFavorite: isFavorite)
        }
    }

    // Cập nhật trạng thái yêu thích vào UserDefaults
    private func updateFavoriteMoviesInUserDefaults(movieID: Int, isFavorite: Bool) {
        var favoriteMovies = UserDefaults.standard.array(forKey: "favoriteMovies") as? [Int] ?? []
        if isFavorite {
            if !favoriteMovies.contains(movieID) {
                favoriteMovies.append(movieID)
            }
        } else {
            favoriteMovies.removeAll { $0 == movieID }
        }
        UserDefaults.standard.set(favoriteMovies, forKey: "favoriteMovies")
    }
}
