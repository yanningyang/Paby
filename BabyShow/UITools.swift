//
//  UITools.swift
//  YuQinClient
//
//  Created by ksn_cn on 16/3/19.
//  Copyright © 2016年 BabyShow. All rights reserved.
//

import Foundation
import MBProgressHUD

open class UITools {
    
    static let sharedInstance = UITools()
    //私有化init方法，保证单例
    fileprivate init(){}
    
    //Toast
    func toast(toView view: UIView, labelText: String) {
        let toast = MBProgressHUD.showAdded(to: view, animated: true)
        toast.mode = MBProgressHUDMode.text
        toast.isUserInteractionEnabled = false
        toast.label.text = labelText
        toast.margin = 10.0
        toast.bezelView.color = UIColor(red: 0.23, green: 0.50, blue: 0.82, alpha: 0.90)
        toast.removeFromSuperViewOnHide = true
        toast.hide(animated: true, afterDelay: 2)
    }
    
    //Toast
    func toast(_ labelText: String) {
        let toast = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        toast.mode = MBProgressHUDMode.text
        toast.isUserInteractionEnabled = false
        toast.offset = CGPoint(x: 0.0, y: UIScreen.main.bounds.height/2 - 100)
        toast.label.text = labelText
        toast.label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.90)
        toast.margin = 10.0
//        toast.bezelView.color = UIColor(red: 0.23, green: 0.50, blue: 0.82, alpha: 0.90)
        toast.bezelView.color = UIColor(red: 226.0/255, green: 189.0/255, blue: 177.0/255, alpha: 0.9)
        toast.removeFromSuperViewOnHide = true
        toast.hide(animated: true, afterDelay: 2)
    }
    
    //加载动画
    func showLoadingAnimation(_ labelText: String) ->MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        HUD.label.text = labelText
        return HUD
    }
    
    //加载动画
    func showLoadingAnimation() ->MBProgressHUD {
        let HUD = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        HUD.label.text = "请稍候..."
        return HUD
    }
    
    //提示检查网络
    func showAlertForNoNetwork() {
        let alertController = UIAlertController(title: "提醒", message: "请检查网络设置", preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { alertAction in
            NSLog("无网络")
        }
        alertController.addAction(ok)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    /// 弹出对话框
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "确定", style: .default) { alertAction in
            print("message: \(message)")
        }
        alertController.addAction(ok)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }

}
