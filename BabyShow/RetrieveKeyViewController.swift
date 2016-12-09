//
//  RetrieveKeyViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/2.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit

class RetrieveKeyViewController: UIViewController {
    
    @IBOutlet weak var topBar: TopBar!
    @IBOutlet weak var phoneNumberText: UITextField!
    @IBOutlet weak var securityCodeText: UITextField!
    @IBOutlet weak var getSecurityCodeBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topBar.setTitle(text: "找回Key")
        self.topBar.setDidSelectLeftBtnClosure { [weak self] in
            self?.view.endEditing(true)
            self?.dismiss(animated: true, completion: nil)
        }
        self.topBar.setDidSelectRightBtnClosure { [weak self] in
            self?.retrieveKey()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    @IBAction func getSecurityCodeAction(_ sender: UIButton) {
        getSecurityCode()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    /// 获取验证码
    func getSecurityCode() {

        let phoneNumber = phoneNumberText.text
        if phoneNumber == nil || phoneNumber!.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            return
        }
        
        URLConnector.request(Router.getSecurityCode(phoneNumber: phoneNumber!), showLoadingAnimation: true, successCallBack: { value in
            if let status = value["data"]["status"].bool {
                if status {
                    
                } else {
                    if let message = value["data"]["message"].string {
                        
                        UITools.sharedInstance.toast(message)
                    }
                }
            }
        })
    }
    
    func retrieveKey() {
        
        let phoneNumber = phoneNumberText.text
        if phoneNumber == nil || phoneNumber!.characters.count != 11 {
            UITools.sharedInstance.toast("手机号码应为11位数字")
            return
        }
        let securityCode = securityCodeText.text
        if securityCode == nil || securityCode!.isEmpty {
            UITools.sharedInstance.toast("请输入验证码")
            return
        }
        
        URLConnector.request(Router.retrieveKey(phoneNumber: phoneNumber!, securityCode: securityCode!.md5), showLoadingAnimation: true, successCallBack: { value in
            if let key = value["data"]["key"].string {
                UITools.sharedInstance.showAlert(title: "登录key", message: key)
            }
        })
    }
}
