//
//  SceneDelegate.swift
//  MovieApp
//
//  Created by Developer 1 on 05/09/2024.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        //Hiển thị màn hình đầu tiên khi vào app
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = LoginVC() // ViewController chính
        window.rootViewController = UINavigationController(rootViewController: rootViewController) // Đặt trong UINavigationController nếu cần
        self.window = window
        window.makeKeyAndVisible()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("Scene đã vào background")
        // Xử lý khi scene vào background
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("Scene chuẩn bị quay lại foreground")
        // Xử lý khi scene quay lại foreground
    }




}

