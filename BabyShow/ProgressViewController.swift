//
//  ProgressViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/2.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit

class ProgressViewController: UIViewController {
    
    var fromViewController: String = ""
    
//    var progressView: HorizontalProgressView!
    var timeLine: TimeLineViewControl!

    @IBOutlet weak var topBar: TopBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        progressView = HorizontalProgressView(frame: CGRect(x: 10, y: 150, width: 300, height: 100))
//        progressView.achievedColor = UIColor.green
//        progressView.unachievedColor = UIColor.gray
//        progressView.progressLevelArray = ["登记", "付费", "上传", "3D还原", "打印", "发货"]
//        progressView.lineMaxHeight = 4
//        progressView.pointMaxRadius = 6
//        progressView.currentLevel = 3
//        progressView.animationDuration = 3
//        progressView.textPosition = .topPostion
//        
//        self.view.addSubview(progressView)
        
//        let times = ["登记", "付费", "上传", "3D还原", "打印", "发货"]
//        timeLine = TimeLineViewControl(time: ["", "", "", "", "", ""], andTimeDescriptionArray: times, andCurrentStatus: 1, andFrame: CGRect(x: 0, y: 150, width: 300, height: 600))
//        self.view.addSubview(timeLine!)
        
        if fromViewController == STORY_BOARD_ID_ChooseProductAttributeViewController {
            topBar.leftBtn.isHidden = true
        }
        
        self.topBar.setTitle(text: "进度")
        self.topBar.rightBtn.isHidden = true
        self.topBar.setDidSelectLeftBtnClosure { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }
        
        //        getProgress()
        let times = ["登记", "付费", "上传", "3D还原", "打印", "发货", "已完成"]
        self.timeLine = TimeLineViewControl(time: ["", "", "", "", "", ""], andTimeDescriptionArray: times, andCurrentStatus: Int32(7), andFrame: CGRect(x: 0, y: 150, width: 300, height: 600))
        self.view.addSubview(self.timeLine!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }

    func getProgress() {
        
        URLConnector.request(Router.getProgress, successCallBack: { value in
            if let progress = value["data"]["progress"].int {
                
                let times = ["登记", "付费", "上传", "3D还原", "打印", "发货", "已完成"]
                self.timeLine = TimeLineViewControl(time: ["", "", "", "", "", ""], andTimeDescriptionArray: times, andCurrentStatus: Int32(progress + 1), andFrame: CGRect(x: 0, y: 150, width: 300, height: 600))
                self.view.addSubview(self.timeLine!)
            }
        })
    }
}
