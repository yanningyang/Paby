//
//  UrlConnection.swift
//  YuQinDriver
//
//  Created by ksn_cn on 2016/11/2.
//  Copyright © 2016年 YuQin. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD
import SwiftyJSON

// 除登录接口之外
open class UrlConnection {
    let host_path = HOST_PATH
    var action: String!
    var commonUrl: String!
    var addCommonParameter: Bool
    
    // 添加公共参数
    init(action: String, addCommonParameter: Bool = true) {
        self.action = action
        self.addCommonParameter = addCommonParameter
        
        if addCommonParameter {
            guard let key = Util.sharedInstance.getUserInfo() , !key.isEmpty else {
//                Util.sharedInstance.logout(withToast: true)
                print("从本地获取key失败!")
                return
            }
            
            var parameters = [String : String]()
            parameters["key"] = key
            
            commonUrl = host_path + "/\(self.action!)" + "?" + encodeUrlParameters(parameters)
        } else {
            commonUrl = host_path + "/\(self.action!)"
        }
        print("commonUrl: \(commonUrl)")
    }
    
    func assembleUrl(_ parameters: [String : String] = [ : ]) -> String {
        if parameters.keys.count == 0 {
            return self.commonUrl
        }
        
        let queryString = encodeUrlParameters(parameters)
        
        if self.addCommonParameter {
            return self.commonUrl + "&" + queryString
        } else {
            return self.commonUrl + "?" + queryString
        }
    }
    
    func encodeUrlParameters(_ parameters: [String : String]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            components.append((escape(key), escape(parameters[key]!)))
        }
        
        return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
    
    /**
     Returns a percent-escaped string following RFC 3986 for a query string key or value.
     
     RFC 3986 states that the following characters are "reserved" characters.
     
     - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
     - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
     
     In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
     query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
     should be percent-escaped in the query string.
     
     - parameter string: The string to be percent-escaped.
     
     - returns: The percent-escaped string.
     */
    open func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
        
        var escaped = ""
        
        //==========================================================================================================
        //
        //  Batching is required for escaping due to an internal bug in iOS 8.1 and 8.2. Encoding more than a few
        //  hundred Chinese characters causes various malloc error crashes. To avoid this issue until iOS 8 is no
        //  longer supported, batching MUST be used for encoding. This introduces roughly a 20% overhead. For more
        //  info, please refer to:
        //
        //      - https://github.com/Alamofire/Alamofire/issues/206
        //
        //==========================================================================================================
        
        if #available(iOS 8.3, OSX 10.10, *) {
            escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
        } else {
            let batchSize = 50
            var index = string.startIndex
            
            while index != string.endIndex {
                let startIndex = index
                let endIndex = string.index(index, offsetBy: batchSize, limitedBy: string.endIndex)
                let range = startIndex..<endIndex!
                
                let substring = string.substring(with: range)
                
                escaped += substring.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? substring
                
                index = endIndex!
            }
        }
        
        return escaped
    }
    
    func request(_ url: String, showLoadingAnimation: Bool = false, successCallBack: @escaping (JSON) -> (), failureCallBack: @escaping (Error) -> () = {_ in return}) {
        
        var HUD: MBProgressHUD!
        if showLoadingAnimation {
            //等待动画
            HUD = UITools.sharedInstance.showLoadingAnimation()
        }
        
        print("😄\(self.action) ===== request: \(url)")
        
        Alamofire.request(url)
            .responseJSON { response in
                
                
                if showLoadingAnimation {
                    //取消等待动画
                    HUD.hide(animated: true)
                }
                
                switch (response.result) {
                case .success(let value):
                    print("✅\(self.action) ===== result: \(value)")
                    let json = JSON(value)
                    if let error_code = json["error_code"].int {
                        if error_code == SYSTEM_ERROR {
                            print("\(url) 接口请求失败")
                        } else if error_code == UNAUTHORIZED {
                            print("\(url) 无权限")
                        } else if error_code == BAD_PARAMETER {
                            print("\(url) 参数错误")
                        } else if error_code == REQUEST_SUCCESS {
                            successCallBack(json)
                        }
                    }
                case .failure(let error):
                    print("❌\(self.action) ===== error: \(error)")
                    failureCallBack(error)
                }
        }
    }
    
    
    /// 后台下载
    func download(urlString: String, localFileName: String, downloadComplete: @escaping (Bool, URL?) -> () = {_, _ in return}, downloadProgress: @escaping (Progress) -> () = {_ in return}) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(localFileName)
            print("fileURL: \(fileURL)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        print("开始下载: \(urlString)")
        Alamofire.download(urlString, to: destination).response { response in
            print("response.request: \(response.request)")
            print("response.destinationURL: \(response.destinationURL)")
            
            if response.error != nil {
                print("\(urlString) ===== download error: \(response.error.debugDescription)")
                downloadComplete(false, response.destinationURL)
            } else if let filePath = response.destinationURL?.path {
                print("下载结束：\(filePath)")
                downloadComplete(true, response.destinationURL)
            } else {
                print("下载目标路径异常")
            }
        }.downloadProgress() { progress in
            print("Download Progress: \(progress.fractionCompleted)")
            downloadProgress(progress)
        }
    }
}
