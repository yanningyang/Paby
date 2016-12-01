//
//  String+MD5.swift
//  YuQinDriver
//
//  Created by ksn_cn on 16/4/21.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation

extension String {
    
    var md5: String! {
        
        let str = self.cString(using: String.Encoding.utf8)
        let strlen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestlen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestlen)
        
        CC_MD5(str!, strlen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestlen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestlen)
        
        return String(format: hash as String)
    }
}
