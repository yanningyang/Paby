//
//  AppDelegate.swift
//  BabyShow
//
//  Created by ksn_cn on 16/5/23.
//  Copyright © 2016年 CQU. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let launchScreenVC = storyboard.instantiateViewController(withIdentifier: "LaunchScreenViewController") as! LaunchScreenViewController
        self.window?.rootViewController = launchScreenVC
        let baby3DVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(closeLaunchScreen(_:)), userInfo: baby3DVC, repeats: false)

        
        return true
    }
    
    func closeLaunchScreen(_ timer: Timer) {
        
//        self.window?.rootViewController = timer.userInfo as! HomeViewController
        checkLogin()
    }
    
    //检查是否已登录
    func checkLogin() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        //判断是否已登录
        let isLogin = UserDefaults.standard.bool(forKey: USER_DEFAULTS_KEY_IS_LOGIN)
        var viewController: UIViewController!
        if isLogin {
            viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
        }
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

