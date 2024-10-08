//
//  ViewController.swift
//  MovieApp
//
//  Created by Developer 1 on 05/09/2024.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white

                // Ví dụ thêm một UILabel vào giữa màn hình
                let label = UILabel()
                label.text = "Hello, No Storyboard!"
                label.textAlignment = .center
                label.frame = view.bounds
                view.addSubview(label)
    }


}

