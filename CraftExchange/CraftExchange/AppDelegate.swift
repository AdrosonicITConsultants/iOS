//
//  AppDelegate.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
//    if KeychainManager.standard.userID != nil && KeychainManager.standard.userID != 0 {
//      let storyboard = UIStoryboard(name: "Tabbar", bundle: nil)
//      let tab = storyboard.instantiateViewController(withIdentifier: "BuyerTabbarController") as! BuyerTabbarController
//      window?.rootViewController = tab
//    }else {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      let vc = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
      window?.rootViewController = vc
//    }
    window?.makeKeyAndVisible()
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }


}

