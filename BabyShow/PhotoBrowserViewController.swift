//
//  PhotoBrowserViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/18.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit

class PhotoBrowserViewController: SGPhotoBrowser {

    var photoModels: [SGPhotoModel] = { return [SGPhotoModel]() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 隐藏 NavigationBar
        self.navigationController?.isNavigationBarHidden = false
        
        self.setupBrowser()
        
        let header = MJRefreshNormalHeader {
            self.loadDataFromLocal()
        }
        header?.lastUpdatedTimeLabel.isHidden = true
        header?.stateLabel.isHidden = true
        self.collectionView.mj_header = header
        self.collectionView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setupBrowser() {
        self.numberOfPhotosPerRow = 4
        self.title = "Photos"
        self.setNumberOfPhotosHandlerBlock() { [weak self] in
            return self?.photoModels.count ?? 0
        }
        self.setphoto(atIndexHandlerBlock: { [weak self] index in
            return self?.photoModels[index]
        })
        self.setReloadHandlerBlock() {
            
        }
        self.setDeleteHandlerBlock() { [weak self] index in
            self?.photoModels.remove(at: index)
            self?.reloadData()
        }
    }
    
    /// 获取图片ids
    func loadData() {
        
        let urlConnection = UrlConnection(action: "pabyApp_imageIds.action")
        urlConnection.request(urlConnection.assembleUrl(), successCallBack: { value in
            if let data = value["data"].array {

                let imageIDs = data.map{ item in item["id"].int! }
                
                self.photoModels.removeAll()
                let downloadUrlConnection = UrlConnection(action: "pabyApp_downloadImage.action")

                self.photoModels = imageIDs.map{ imageID in
                    let url = URL(string: downloadUrlConnection.assembleUrl(["id" : "\(imageID)"]))
                    let model = SGPhotoModel()
                    model.photoURL = url!
                    model.thumbURL = url!
                    return model
                }
                
                self.reloadData()
                self.collectionView.mj_header.endRefreshing()
            }
        })
    }
    
    func loadDataFromLocal() {
        self.photoModels.removeAll()
        var i = 1;
        repeat {
            if let path = Bundle.main.path(forResource: String(format: "baby_00%d", i), ofType: ".jpg") {
                
                let url = URL(fileURLWithPath: path)
                let model = SGPhotoModel()
                model.photoURL = url
                model.thumbURL = url
                self.photoModels.append(model)
            }
            i += 1
        } while(i < 10)
        
        self.reloadData()
        self.collectionView.mj_header.endRefreshing()
    }
}
