//
//  UIColor+Hex.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/1/23.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import Foundation

extension UIColor {
    public class func colorWithHex(_ hexColor: Int, alpha: Float) -> UIColor {
        let red = (Float)((hexColor & 0xFF0000) >> 16) / 255.0
        let green = (Float)((hexColor & 0x00FF00) >> 8) / 255.0
        let blue = (Float)(hexColor & 0x0000FF) / 255.0
        return UIColor(colorLiteralRed: red, green: green, blue: blue, alpha: alpha)
    }
    
    public class func colorWithHex(_ hexColor: Int) ->UIColor {
        return colorWithHex(hexColor, alpha: 1.0)
    }
}
