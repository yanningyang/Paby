//
//  URLConnector.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/12/9.
//  Copyright © 2016年 CQU. All rights reserved.
//

import Foundation
import Alamofire
import MBProgressHUD
import SwiftyJSON

enum Router: URLRequestConvertible {
    
    case login(key: String)
    case getSecurityCode(phoneNumber: String)
    case paymentStatus
    case getSignedOrderString(material: String, size: String)
    case faceDataReady
    case faceData
    case imageIds
    case faceDataRefresh
    case imagesRefresh
    case faceDataDownloadSuccess
    case imagesDownloadSuccess
    case getGestationalWeeks
    case getProgress
    case retrieveKey(phoneNumber: String, securityCode: String)
    case downloadImage(id: String)
    
    static let baseURLString = HOST_PATH
    
    func asURLRequest() throws -> URLRequest {
        var parameters: [String : String] = {
            guard let key = Util.sharedInstance.getUserInfo() , !key.isEmpty else {
                print("从本地获取key失败!")
                return [String: String]()
            }
            return ["key" : key]
        }()
        
        let result: (path: String, parameters: Parameters) = {
            switch self {
            case let .login(key):
                return ("/pabyApp_login.action", ["key": key])
            case let .getSecurityCode(phoneNumber):
                parameters["phoneNumber"] = phoneNumber
                return ("/pabyApp_getSecurityCode.action", parameters)
            case .paymentStatus:
                return ("/pabyApp_paymentStatus.action", parameters)
            case let .getSignedOrderString(material, size):
                parameters["material"] = material
                parameters["size"] = size
                return ("/pabyApp_getSignedOrderString.action", parameters)
            case .faceDataReady:
                return ("/pabyApp_faceDataReady.action", parameters)
            case .faceData:
                return ("/pabyApp_faceData.action", parameters)
            case .imageIds:
                return ("/pabyApp_imageIds.action", parameters)
            case .faceDataRefresh:
                return ("/pabyApp_faceDataRefresh.action", parameters)
            case .imagesRefresh:
                return ("/pabyApp_imagesRefresh.action", parameters)
            case .faceDataDownloadSuccess:
                return ("/pabyApp_faceDataDownloadSuccess.action", parameters)
            case .imagesDownloadSuccess:
                return ("/pabyApp_imagesDownloadSuccess.action", parameters)
            case .getGestationalWeeks:
                return ("/pabyApp_getGestationalWeeks.action", parameters)
            case .getProgress:
                return ("/pabyApp_getProgress.action", parameters)
            case let .retrieveKey(phoneNumber, securityCode):
                parameters["phoneNumber"] = phoneNumber
                parameters["securityCode"] = securityCode
                return ("/pabyApp_retrieveKey.action", parameters)
            case let .downloadImage(id):
                parameters["id"] = id
                return ("/pabyApp_downloadImage.action", parameters)
            }
        }()
        
        let url = try Router.baseURLString.asURL()
        let urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        return try URLEncoding.default.encode(urlRequest, with: result.parameters)
    }
}

open class URLConnector {
    
    class func request(_ urlRequest: URLRequestConvertible, showLoadingAnimation: Bool = false, successCallBack: @escaping (JSON) -> (), failureCallBack: @escaping (Error) -> () = {_ in return}) {
        
        var HUD: MBProgressHUD!
        if showLoadingAnimation {
            //等待动画
            HUD = UITools.sharedInstance.showLoadingAnimation()
        }
        
        print("😄urlRequest: ", urlRequest)
        
        Alamofire.request(urlRequest)
            .responseJSON { response in
                
                if showLoadingAnimation {
                    //取消等待动画
                    HUD.hide(animated: true)
                }
                
                switch (response.result) {
                case .success(let value):
                    print("✅\(urlRequest): ", value)
                    let json = JSON(value)
                    if let error_code = json["error_code"].int {
                        if error_code == SYSTEM_ERROR {
                            print("接口请求失败: ", urlRequest)
                        } else if error_code == UNAUTHORIZED {
                            print("无权限: ", urlRequest)
                        } else if error_code == BAD_PARAMETER {
                            print("参数错误: ", urlRequest)
                        } else if error_code == REQUEST_SUCCESS {
                            successCallBack(json)
                        }
                    }
                case .failure(let error):
                    print("❌\(urlRequest): ", error)
                    failureCallBack(error)
                }
        }
    }

    /// 后台下载
    class func download(_ urlRequest: URLRequestConvertible, localFileName: String, downloadComplete: @escaping (Bool, URL?) -> () = {_, _ in return}, downloadProgress: @escaping (Progress) -> () = {_ in return}) {
        
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(localFileName)
            print("fileURL: \(fileURL)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        print("开始下载: \(urlRequest)")
        Alamofire.download(urlRequest, to: destination).response { response in
            print("response.request: \(response.request)")
            print("response.destinationURL: \(response.destinationURL)")
            
            if response.error != nil {
                print("\(urlRequest) ===== download error: \(response.error.debugDescription)")
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
