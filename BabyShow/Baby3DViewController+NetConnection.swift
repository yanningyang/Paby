//
//  Baby3DViewController+NetConnection.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/10.
//  Copyright © 2016年 CQU. All rights reserved.
//

import Foundation

extension Baby3DViewController {
    
    /// 获取付费状态
    func getPaymentStatus() {
        
        let urlConnection = UrlConnection(action: "pabyApp_paymentStatus.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let status = value["data"]["status"].bool  {
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(status, forKey: USER_DEFAULTS_KEY_PAID)
                userDefaults.synchronize()
                
                self.payBtn.isHidden = status
            }
        })
        
    }
    
    /// 获取3D数据就绪状态
    func getFaceDataReady() {
        
        let urlConnection = UrlConnection(action: "pabyApp_faceDataReady.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let status = value["data"]["status"].bool  {
                
                let userDefaults = UserDefaults.standard
                userDefaults.set(status, forKey: USER_DEFAULTS_KEY_FACE_DATA_READY)
                userDefaults.synchronize()
                
                if status {
                    self.getFaceDataRefresh()
                } else {
                    self.tipLabel.isHidden = false
                    self.tipLabel.text = "暂无数据"
                }
            }
        })
    }
    
    /// 获取3D数据是否更新
    func getFaceDataRefresh() {
        
        let urlConnection = UrlConnection(action: "pabyApp_faceDataRefresh.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let status = value["data"]["status"].bool  {
                if status {
                    self.getFaceData()
                    
                    self.tipLabel.isHidden = false
                    self.tipLabel.text = "正在下载3D数据..."
                } else {
                    
                    // 从本地磁盘加载3D数据
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentsURL.appendingPathComponent(self.localFaceDataPath)
                    let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
                    if !fileExists {
                        self.getFaceData()
                        
                        self.tipLabel.isHidden = false
                        self.tipLabel.text = "正在下载3D数据..."
                    }
                }
            }
        })
    }
    
    /// 获取3D数据
    func getFaceData() {
        
        let urlConnection = UrlConnection(action: "pabyApp_faceData.action")
        urlConnection.download(urlString: urlConnection.assembleUrl(), localFileName: localFaceDataPath, downloadComplete: { success, destinationURL in
            UITools.sharedInstance.toast(success ? "下载3D数据成功" : "下载3D数据失败")
            if success {
                self.tipLabel.isHidden = true
                
                // 设置3d场景
                self.setupScene(from: destinationURL)
                // 设置摄像机
                self.setupCamera()
                
                self.faceDataDownloadSuccess()
            } else {
                
            }
        }, downloadProgress: { progress in
            
        })
    }
    
    /// 确认3D数据下载成功
    func faceDataDownloadSuccess() {
        
        let urlConnection = UrlConnection(action: "pabyApp_faceDataDownloadSuccess.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let error_code = value["error_code"].int {
                if error_code == SYSTEM_ERROR {
                    
                }
            }
        })
    }
    
    /// 获取孕周
    func getGestationalWeeks() {
        
        let urlConnection = UrlConnection(action: "pabyApp_getGestationalWeeks.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let weeks = value["data"]["gestational_weeks"].int {
                
                self.numberOfWeeksLabel.text = "第 \(weeks) 周"
            }
        })
    }
    


}
