//
//  LoginViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 16/8/18.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {

    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    // 键盘位移量
    var keyboardOffset: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:))))
        
        let image = Util.sharedInstance.getImage(from: UIColor(red: 226.0/255, green: 189.0/255, blue: 177.0/255, alpha: 1))
        loginBtn.setBackgroundImage(image, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK: - Gesture handle
    func onTapBackgroundView(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    //MARK: - Actions
    @IBAction func loginBtnAction(_ sender: UIButton) {
        self.view.endEditing(true)
        login()
        
//        let userDefaults = UserDefaults.standard
//        userDefaults.set("Y8e4Ea2u".md5, forKey: USER_DEFAULTS_KEY_LOGIN_KEY)
//        userDefaults.set(true, forKey: USER_DEFAULTS_KEY_IS_LOGIN)
//        userDefaults.synchronize()
//        
//        let window = UIApplication.shared.keyWindow!
//        var viewController: UIViewController!
//        viewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
//        window.rootViewController = viewController
//        window.makeKeyAndVisible()
    }
    
    /// MARK: - network request
    
    /// 登录
    func login() {
        
        guard let loginKey = keyTextField.text , !loginKey.isEmpty else {
            UITools.sharedInstance.toast("请输入登录Key")
            return
        }
        
        URLConnector.request(Router.login(key: loginKey.md5), showLoadingAnimation: true,
            successCallBack: { value in
            if let status = value["data"]["status"].bool {
                if status {
                    
                    let userDefaults = UserDefaults.standard
                    userDefaults.set(loginKey.md5, forKey: USER_DEFAULTS_KEY_LOGIN_KEY)
                    userDefaults.set(true, forKey: USER_DEFAULTS_KEY_IS_LOGIN)
                    userDefaults.synchronize()
                    
                    let window = UIApplication.shared.keyWindow!
                    var viewController: UIViewController!
                    viewController = self.storyboard!.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
                    window.rootViewController = viewController
                    window.makeKeyAndVisible()
                    
                    //上传token
                    //                    Util.sharedInstance.updateDeviceToken()
                } else {
                    let userDefaults = UserDefaults.standard
                    userDefaults.removeObject(forKey: "key")
                    userDefaults.synchronize()
                    UITools.sharedInstance.toast( TOAST_WRONG_KEY )
                }
            }
        })
    }
    
    /// 键盘将要显示
    ///
    /// - parameter notification: 通知
    func keyboardWillShow(notification: NSNotification) {
        
        let userInfo  = notification.userInfo!
        let keyBoardBounds = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
//        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        let keyboardHeight = keyBoardBounds.size.height
        let loginBtnFrame = loginBtn.superview?.convert(loginBtn.frame, to: self.view)
        keyboardOffset = (loginBtnFrame!.origin.y + loginBtnFrame!.size.height + 20) - (self.view.frame.size.height - keyboardHeight)
        
        self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardOffset)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
//        let userInfo  = notification.userInfo!
//        let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        
        self.view.transform = CGAffineTransform(translationX: 0, y: 0)
    }
}
