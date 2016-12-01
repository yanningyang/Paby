//
//  ChooseProductAttributeViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/3.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit

class ChooseProductAttributeViewController: UIViewController {
    
    @IBOutlet weak var topBar: TopBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topBar.setTitle(text: "选择商品属性")
        self.topBar.setDidSelectLeftBtnClosure { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        self.topBar.setDidSelectRightBtnClosure { [weak self] in
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
}
