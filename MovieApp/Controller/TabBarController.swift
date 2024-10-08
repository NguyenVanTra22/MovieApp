//
//  TabBarController.swift
//  MovieApp
//
//  Created by Developer 1 on 18/09/2024.
//

//import UIKit
//
//class TabBarController: UITabBarController {
//
//    override func viewDidLoad() {
//           super.viewDidLoad()
//           // Tạo view controller cho tab danh sách phim
//           let movieListVC = MovieListVC()
//           let movieListNav = UINavigationController(rootViewController: movieListVC)
//           movieListNav.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "film"), tag: 0)
//
//           // Tạo view controller cho tab đăng ký tài khoản
//           let profileVC = ProfileController(nibName: "ProfileView", bundle: nil)
//           let profileNav = UINavigationController(rootViewController: profileVC)
//           profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)
//
//           // Gán các view controller vào Tab Bar Controller
//           viewControllers = [movieListNav, profileNav]
//       }
//
//}
import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tạo view controller cho tab danh sách phim
        let movieListVC = MovieListVC() // Giả định MovieListVC đã được định nghĩa
        let movieListNav = UINavigationController(rootViewController: movieListVC)
        movieListNav.tabBarItem = UITabBarItem(title: "Movies", image: UIImage(systemName: "film"), tag: 0)

        // Tạo view controller cho tab hồ sơ
        let profileVC = ProfileController() // Hoặc nếu cần sử dụng nib: ProfileController(nibName: "ProfileView", bundle: nil)
        let profileNav = UINavigationController(rootViewController: profileVC)
        profileNav.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 1)

        // Gán các view controller vào Tab Bar Controller
        viewControllers = [movieListNav, profileNav]
    }
}
