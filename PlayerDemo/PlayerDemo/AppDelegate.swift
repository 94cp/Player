//
//  AppDelegate.swift
//  PlayerDemo
//
//  Created by chenp on 2018/12/2.
//  Copyright © 2018 chenp. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let tabBarController = UITabBarController()
        
        tabBarController.addChild(UINavigationController(rootViewController: DemoViewController()))
        tabBarController.children.first?.tabBarItem.title = "播放示例"
        tabBarController.children.first?.tabBarItem.image = UIImage(named: "tab_player")
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
}

