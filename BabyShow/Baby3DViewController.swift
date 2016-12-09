//
//  Baby3DViewController.swift
//  BabyShow
//
//  Created by ksn_cn on 16/7/28.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit
import SceneKit
import AVFoundation
import FLAnimatedImage
import SwiftyJSON
import MBProgressHUD

class Baby3DViewController: UIViewController, MWPhotoBrowserDelegate {
    
    /// 本地 dae 文件路径
    let localFaceDataPath = "model.scnassets/face.dae"
    /// 定时器
    var timer: Timer?
    /// 播放器
    var player: AVAudioPlayer!
    
    /// IBOutlet
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var bgImageView: FLAnimatedImageView!
    @IBOutlet weak var babySCNView: SCNView!
    @IBOutlet weak var txyBtn: UIButton!
    @IBOutlet weak var photosBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var numberOfWeeksLabel: UILabel!
    @IBOutlet weak var systemTimeLabel: UILabel!
    @IBOutlet weak var showProgressBtn: UIButton!
    @IBOutlet weak var payBtn: UIButton!
    @IBOutlet weak var tipLabel: UILabel!
    
    @IBOutlet weak var shareBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var shareBtnheight: NSLayoutConstraint!
    
    /// 背景图片
    let bgImages = ["forenoon", "afternoon", "night"]
    var selectedBgImageIndex = 2
    
    /// Retrieving nodes
    var mainSkeleton: SCNNode!
    var babyNode: SCNNode!
    
    /// Nodes to manipulate the camera
    let cameraYHandle = SCNNode()
    let cameraXHandle = SCNNode()
    
    /// 存储3D模型旋转和移动相关数据
    var startLocation: CGPoint!
    var lastLocation: CGPoint!
    var currentAngleX: Float = 0.0
    var currentAngleY: Float = 0.0
    
    /// 存储3D模型的缩放相关数据
    var lastCameraYFov: Double!
    
    internal var panningTouch: UITouch?
    
    /// 图片ids
    var imageIDs = [Int]()
    /// 图片List
    var photos = [MWPhoto]()
    /// 图片浏览器
    var imageBrowser: MWPhotoBrowser?
    var photoBrowser: SGPhotoBrowser!
    
    /// Audio 输入设备
    var inputs: NSArray?
    /// 麦克风🎤
    var microphone: EZMicrophone?
    /// 胎心音设备是否插入
    lazy var audioDeviceIsPlugged: Bool = { false }()
    
    /// 是否正在下载3D数据
    lazy var isDownloading: Bool = { true }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()

        // 切换背景
        timerCallback()
        // 播放背景音乐
        playBgm()
        // 定时任务：每分钟检测时间
        timer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(timerCallback), userInfo: nil, repeats: true)
        
        // 胎心音初始化设置
        self.audioSettingInit()
        
        // 从本地磁盘加载3D数据
        self.load3DDataFromLocal()
        
        // 获取孕周
        self.getGestationalWeeks()
        // 获取支付状态
        self.getPaymentStatus()
        // 查询3D数据是否就绪
        self.getFaceDataReady()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapBackgroundView(_:))))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 隐藏 NavigationBar
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return selectedBgImageIndex == 2 ? .lightContent : .default
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
    //--------------------------------------------------------------------------
    // MARK: - MWPhotoBrowserDelegate
    //--------------------------------------------------------------------------
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(photos.count)
    }
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        if index < UInt(self.photos.count) {
            return self.photos[Int(index)]
        }
        return nil
    }
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, thumbPhotoAt index: UInt) -> MWPhotoProtocol! {
        if index < UInt(self.photos.count) {
            return self.photos[Int(index)]
        }
        return nil
    }
    
    //--------------------------------------------------------------------------
    // MARK: - Action
    //--------------------------------------------------------------------------
    @IBAction func closeBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func txyBtnAction(_ sender: UIButton) {
        if self.audioPlot.isHidden && !self.audioDeviceIsPlugged {
            UITools.sharedInstance.toast("请插入胎心音设备")
            return
        }
        self.audioPlot.isHidden = !self.audioPlot.isHidden
        self.audioPlot.isHidden ? microphone!.stopFetchingAudio() : microphone!.startFetchingAudio()
        self.audioPlot.clear()
    }
    @IBAction func photosBtnAction(_ sender: UIButton) {
        showImageBrowser()
    }
    @IBAction func shareBtnAction(_ sender: UIButton) {
        share()
    }
    @IBAction func didPressShowProgressBtn(_ sender: UIButton) {
        guard let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ProgressViewController") as? ProgressViewController else {
            return
        }
        self.present(viewController, animated: true, completion: nil)
    }
    @IBAction func didPressPayBtn(_ sender: UIButton) {
        guard let viewController = self.storyboard!.instantiateViewController(withIdentifier: "ChooseProductAttributeViewController") as? ChooseProductAttributeViewController else {
            return
        }
        self.present(viewController, animated: true, completion: nil)
    }
    
    // MARK: - Gesture handle
    func onTapBackgroundView(_ sender: UITapGestureRecognizer) {
        
        if !isDownloading {
            self.getFaceDataReady()
        }
    }
    
    // MARK: - Image Browser
    /// 展示图片
    func showImageBrowser() {
        self.photoBrowser = PhotoBrowserViewController()
        self.navigationController?.pushViewController(self.photoBrowser, animated: true)
        
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ImageBrowserViewController") as! ImageBrowserViewController
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - 分享
    /// 分享
    fileprivate func share() {
        
        guard let snapshot = self.snapshot(self.view) else {
            print("snapshot is nil!")
            return
        }

        var items = [AnyObject]()
        items.append(snapshot)
        let activity = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activity.excludedActivityTypes = [.airDrop, .addToReadingList, .assignToContact, .copyToPasteboard, .mail, .message, .openInIBooks, .postToFacebook, .postToFlickr, .postToVimeo, .postToTwitter, .print, .saveToCameraRoll]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let popover = activity.popoverPresentationController
            if popover != nil {
                popover!.sourceView = self.shareBtn
                popover!.permittedArrowDirections = .any
            }
        }
        
        self.present(activity, animated: true, completion: nil)
    }
    
    /// 截图
    fileprivate func snapshot(_ view: UIView) -> UIImage? {
        print(view.bounds)
        var cutSize = view.bounds.size
        cutSize.height -= 110
        UIGraphicsBeginImageContextWithOptions(cutSize, false, 0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: false)
        let snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return snapshot
        
//        guard snapshot != nil else {
//            print("snapshot is nil!")
//            return nil
//        }
//        let imageData = UIImagePNGRepresentation(snapshot!)
//        let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
//        let imgSavePath = documentDir! + "/snapshot.png"
//        print("imgSavePath: \(imgSavePath)")
//        try? imageData?.write(to: URL(fileURLWithPath: imgSavePath), options: [.atomic])
//        
//        return UIImage(contentsOfFile: imgSavePath)
    }

    //--------------------------------------------------------------------------
    // MARK: - Utility
    //--------------------------------------------------------------------------
    
    /// 播放背景音乐
    func playBgm() {
        
        if player == nil {
            
            let musicFilePath = Bundle.main.path(forResource: "bgm", ofType: "mp3")
            let musicUrl = URL(fileURLWithPath: musicFilePath!)
            
            do {
                player = try AVAudioPlayer(contentsOf: musicUrl)
            } catch let error as NSError {
                print("Could not create audio player: \(error)")
            }
        }
        if player!.isPlaying {
            return
        }
        player!.prepareToPlay()
        player!.numberOfLoops = -1
        player!.play()
    }
    
    /// 定时器回调，切换背景，更新时间显示
    func timerCallback() {
        
        // 更新系统时间
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let systemTime = dateFormatter.string(from: Date())
        systemTimeLabel.text = systemTime
        
        // 切换背景
        if isBetween("08:00:00", toTime: "12:59:59") {
            setBgImage(0)
            changeBtnImg(type: 2)
        } else if isBetween("13:00:00", toTime: "19:59:59") {
            setBgImage(1)
            changeBtnImg(type: 2)
        } else {
            setBgImage(2)
            changeBtnImg(type: 1)
        }
    }
    
    /// 判断时间范围
    func isBetween(_ fromTime: String, toTime: String) -> Bool {
        let fromDate = date(from: fromTime)
        let toDate = date(from: toTime)
        let currentDate = Date()
        
        if currentDate.compare(fromDate) == .orderedDescending && currentDate.compare(toDate) == .orderedAscending {
            return true
        }
        return false
    }
    
    /// 将time转换为Date
    func date(from time: String) -> Date {
        
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyMMdd"
        
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyMMdd HH:mm:ss"
        
        let yyMMdd = dateFormatter1.string(from: Date())
        
        let date = dateFormatter2.date(from: yyMMdd + " " + time)
        
        return date!
    }
    
    func setBgImage(_ bgImageIndex: Int) {
        
        if bgImageView.isAnimating {
            if bgImageIndex == selectedBgImageIndex {
                return
            }
            bgImageView.stopAnimating()
        }
        selectedBgImageIndex = bgImageIndex
        let path = Bundle.main.path(forResource: bgImages[bgImageIndex], ofType: "gif")
        let gifImg = try! FLAnimatedImage(animatedGIFData: Data(contentsOf: URL(fileURLWithPath: path!)))
        bgImageView.animatedImage = gifImg
        
        // 根据背景色修改statusBar前景色
        self.setNeedsStatusBarAppearanceUpdate()
        
//        // 设置label颜色
//        if selectedBgImageIndex == 2 {
//            self.systemTimeLabel.textColor = UIColor.whiteColor()
//        } else {
//            self.systemTimeLabel.textColor = UIColor.blackColor()
//        }
    }
    
    func setupUI() {
        
        // 隐藏 NavigationBar
        self.navigationController?.isNavigationBarHidden = true
        
        payBtn.isHidden = true
        tipLabel.isHidden = true
        
        // set the sceneView background color to clear
        babySCNView.backgroundColor = UIColor.clear
        
        let edgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        self.txyBtn.imageEdgeInsets = edgeInsets
        self.photosBtn.imageEdgeInsets = edgeInsets
        self.shareBtn.imageEdgeInsets = edgeInsets
    }
    
    
    /// 改变按钮image
    ///
    /// - Parameter type: 1为夜间模式，2为白天模式
    func changeBtnImg(type: Int) {
        self.txyBtn.setImage(UIImage(named: "BtnTxy\(type)"), for: .normal)
        self.photosBtn.setImage(UIImage(named: "BtnPhoto\(type)"), for: .normal)
        self.shareBtn.setImage(UIImage(named: "BtnShare\(type)"), for: .normal)
    }

    func load3DDataFromLocal() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(localFaceDataPath)
        let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
        print("🔥fileExists: \(fileExists)")
        if fileExists {
            // 设置3d场景
            setupScene(from: fileURL)
            // 设置摄像机
            setupCamera()
        }
    }
}
