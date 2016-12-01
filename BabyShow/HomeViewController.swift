//
//  HomeViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 16/8/8.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit

class HomeViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 隐藏 NavigationBar
        self.isNavigationBarHidden = true
        // 取消左边缘右滑时，当前ViewController pop出栈
        self.interactivePopGestureRecognizer?.isEnabled = false
        
        let image = Util.sharedInstance.getImage(from: UIColor(red: 226.0/255, green: 189.0/255, blue: 177.0/255, alpha: 1))
        self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        self.navigationBar.barStyle = .black
//        self.navigationBar.isTranslucent = false
        self.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
