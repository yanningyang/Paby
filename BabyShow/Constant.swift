//
//  Constant.swift
//  CallTaxiDriverClient
//
//  Created by ksn_cn on 16/11/2.
//  Copyright © 2016年 ChongQing University. All rights reserved.
//

import Foundation

// APP ID
public let APP_ID = ""

/// MARK -- 接口地址
#if DEBUG
    // 开发环境
    public let HOST_NAME = "http://139.224.80.248"
#else
    // 生产环境
    public let HOST_NAME = "http://oa.yuqinqiche.com"
#endif

public let HOST_PATH = HOST_NAME + "/Dppepper/app"
//public let HOST_PATH = HOST_NAME + "/dppepper/app"

// 检查版本地址
public let CheckUpdateUrl = HOST_NAME + "/apk/DriverAPPUpdate.xml"

// 接口请求失败
public let REQUEST_SUCCESS = 0
// 接口请求失败
public let SYSTEM_ERROR = -1
// 鉴权失败
public let UNAUTHORIZED = -9001
// 接口参数错误
public let BAD_PARAMETER = -9002

/// Toast
public let TOAST_WRONG_KEY = "您输入的key不正确，请重新输入"


/// UserDefaults Key
public let USER_DEFAULTS_KEY_IS_LOGIN = "isLogin"
public let USER_DEFAULTS_KEY_PAID = "paid"
public let USER_DEFAULTS_KEY_LOGIN_KEY = "key"
public let USER_DEFAULTS_KEY_FACE_DATA_READY = "face_data_ready"


/// story board id
public let STORY_BOARD_ID_ChooseProductAttributeViewController = "ChooseProductAttributeViewController"
