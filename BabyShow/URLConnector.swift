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
    
    class func configSSL() {
        //认证相关设置
        let manager = Alamofire.SessionManager.default;
        manager.delegate.sessionDidReceiveChallenge = { session, challenge in
            //认证服务器证书
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                print("服务端证书认证！")
                let serverTrust:SecTrust = challenge.protectionSpace.serverTrust!
                let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0)!
                let remoteCertificateData = CFBridgingRetain(SecCertificateCopyData(certificate))!
                let cerPath = Bundle.main.path(forResource: "tomcat", ofType: "cer")!
                let cerUrl = URL(fileURLWithPath:cerPath)
                let localCertificateData = try! Data(contentsOf: cerUrl)
                
                if (remoteCertificateData.isEqual(localCertificateData) == true) {
                    
                    let credential = URLCredential(trust: serverTrust)
                    challenge.sender?.use(credential, for: challenge)
                    return (URLSession.AuthChallengeDisposition.useCredential,
                            URLCredential(trust: challenge.protectionSpace.serverTrust!))
                    
                } else {
                    return (.cancelAuthenticationChallenge, nil)
                }
            }
            //认证客户端证书
            else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate {
                print("客户端证书认证！")
                //获取客户端证书相关信息
                let identityAndTrust:IdentityAndTrust = URLConnector.extractIdentity();
                
                let urlCredential:URLCredential = URLCredential(
                    identity: identityAndTrust.identityRef,
                    certificates: identityAndTrust.certArray as? [AnyObject],
                    persistence: URLCredential.Persistence.forSession);
                
                return (.useCredential, urlCredential);
            }
                // 其它情况（不接受认证）
            else {
                print("其它情况（不接受认证）")
                return (.cancelAuthenticationChallenge, nil)
            }
        }

    }
    
    //获取客户端证书相关信息
    class func extractIdentity() -> IdentityAndTrust {
        var identityAndTrust:IdentityAndTrust!
        var securityError:OSStatus = errSecSuccess
        
        let path: String = Bundle.main.path(forResource: "client", ofType: "p12")!
        let PKCS12Data = NSData(contentsOfFile:path)!
        let key : NSString = kSecImportExportPassphrase as NSString
        let options : NSDictionary = [key : "123456"] //客户端证书密码
        //create variable for holding security information
        //var privateKeyRef: SecKeyRef? = nil
        
        var items : CFArray?
        
        securityError = SecPKCS12Import(PKCS12Data, options, &items)
        
        if securityError == errSecSuccess {
            let certItems:CFArray = items as CFArray!;
            let certItemsArray:Array = certItems as Array
            let dict:AnyObject? = certItemsArray.first;
            if let certEntry:Dictionary = dict as? Dictionary<String, AnyObject> {
                // grab the identity
                let identityPointer:AnyObject? = certEntry["identity"];
                let secIdentityRef:SecIdentity = identityPointer as! SecIdentity!
                print("\(identityPointer)  :::: \(secIdentityRef)")
                // grab the trust
                let trustPointer:AnyObject? = certEntry["trust"]
                let trustRef:SecTrust = trustPointer as! SecTrust
                print("\(trustPointer)  :::: \(trustRef)")
                // grab the cert
                let chainPointer:AnyObject? = certEntry["chain"]
                identityAndTrust = IdentityAndTrust(identityRef: secIdentityRef,
                                                    trust: trustRef, certArray:  chainPointer!)
            }
        }
        return identityAndTrust;
    }
    
    class func request(_ urlRequest: URLRequestConvertible, showLoadingAnimation: Bool = false, successCallBack: @escaping (JSON) -> (), failureCallBack: @escaping (Error) -> () = {_ in return}) {
        
        var HUD: MBProgressHUD!
        if showLoadingAnimation {
            //等待动画
            HUD = UITools.sharedInstance.showLoadingAnimation()
        }
        
//        URLConnector.configSSL()
        
        print("😄urlRequest: ", try! urlRequest.asURLRequest())
        
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
        
        print("开始下载: \(urlRequest)")
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(localFileName)
            print("fileURL: \(fileURL)")
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
//        let config = URLSessionConfiguration.background(withIdentifier: "com.app.dppepper.background")
//        let sessionManager = Alamofire.SessionManager(configuration: config)
//        let delegate: Alamofire.SessionDelegate = sessionManager.delegate
//        
//        delegate.dataTaskDidReceiveResponse = { session, dataTask, response in
//            print("response: ", response)
//            return URLSession.ResponseDisposition.allow
//        }
//        delegate.downloadTaskDidFinishDownloadingToURL = { session, downloadTask, url in
//            print("下载结束：\(url)")
//            downloadComplete(true, url)
//        }
//        delegate.taskDidComplete = { session, task, error in
//            if error != nil {
//                print("\(urlRequest) download error: \(error.debugDescription)")
//                downloadComplete(false, URL(fileURLWithPath: ""))
//            }
//        }
//        sessionManager.download(urlRequest, to: destination)
        
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

//定义一个结构体，存储认证相关信息
struct IdentityAndTrust {
    var identityRef:SecIdentity
    var trust:SecTrust
    var certArray:AnyObject
}
