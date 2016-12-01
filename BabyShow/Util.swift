//
//  Util.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/2.
//  Copyright © 2016年 CQU. All rights reserved.
//

import Foundation

open class Util {
    
    static let sharedInstance = Util()
    //私有化init方法，保证单例
    fileprivate init(){}
    
    //获取登录用户的key
    open func getUserInfo() -> String? {
        let userDefault = UserDefaults.standard
        let key = userDefault.string(forKey: "key")
        return key
    }
    
    open func getImage(from color: UIColor) -> UIImage? {
        var image: UIImage?
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        if let ctx = UIGraphicsGetCurrentContext() {
            ctx.setFillColor(color.cgColor)
            ctx.fill(rect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return image
    }
}
