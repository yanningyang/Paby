//
//  TopBar.swift
//  BabyShow
//
//  Created by ksn_cn on 2016/11/19.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit
import SnapKit

class TopBar: UIView {
    
    var titleLabel: UILabel!
    var leftBtn: UIButton!
    var rightBtn: UIButton!
    
    private var didSelectLeftBtnClosure: (() -> Void)!
    private var didSelectRightBtnClosure: (() -> Void)!

    
    /// initWithFrame
    ///
    /// - Parameter frame: Default: CGRect(x: 0, y: -20, width: CGFloat, height: 64)
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initTopBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initTopBar()
    }
    
    private func initTopBar() {
//        self.backgroundColor = UIColor(red: 34.0/255, green: 189.0/255, blue: 246.0/255, alpha: 0.8)
        self.backgroundColor = UIColor(red: 226.0/255, green: 189.0/255, blue: 177.0/255, alpha: 1)
        
        self.titleLabel = UILabel()
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        
        self.leftBtn = UIButton()
        self.leftBtn.setTitle("返回", for: .normal)
        self.leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.leftBtn.setTitleColor(UIColor.white, for: .normal)
        
        self.rightBtn = UIButton()
        self.rightBtn.setTitle("确定", for: .normal)
        self.rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.rightBtn.setTitleColor(UIColor.white, for: .normal)
        
        self.addSubview(leftBtn)
        self.addSubview(titleLabel)
        self.addSubview(rightBtn)
        
        self.leftBtn.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(44)
            make.bottom.equalTo(self.snp.bottom)
            make.left.equalTo(self.snp.left)
        }
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.leftBtn.snp.centerY)
            make.centerX.equalTo(self.snp.centerX)
        }
        self.rightBtn.snp.makeConstraints { make in
            make.width.equalTo(60)
            make.height.equalTo(44)
            make.bottom.equalTo(self.snp.bottom)
            make.right.equalTo(self.snp.right)
        }
        
        self.leftBtn.addTarget(self, action: #selector(self.didSelectLeftBtn), for: .touchUpInside)
        self.rightBtn.addTarget(self, action: #selector(self.didSelectRightBtn), for: .touchUpInside)
    }

    func didSelectLeftBtn() {
        guard self.didSelectLeftBtnClosure != nil else {
            return
        }
        self.didSelectLeftBtnClosure()
    }
    
    func didSelectRightBtn() {
        guard self.didSelectRightBtnClosure != nil else {
            return
        }
        self.didSelectRightBtnClosure()
    }
    
    func setDidSelectLeftBtnClosure(_ closure: @escaping () -> Void) {
        self.didSelectLeftBtnClosure = closure
    }
    
    func setDidSelectRightBtnClosure(_ closure: @escaping () -> Void) {
        self.didSelectRightBtnClosure = closure
    }
    
    func setTitle(text: String) {
        self.titleLabel.text = text
    }
    
    func setLeftBtnText(text: String) {
        self.leftBtn.setTitle(text, for: .normal)
    }
    
    func setRightBtnText(text: String) {
        self.rightBtn.setTitle(text, for: .normal)
    }
}
