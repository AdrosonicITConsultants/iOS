//
//  AppDelegate.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import FBSDKCoreKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
    var window: UIWindow?
    var showDemoVideo: Bool = false
    var registerUser: CXUser?
    var tabbar: BuyerTabbarController?
    var artisanTabbar: ArtisanTabbarController?
    var wishlistIds: [Int]?
    var notificationToken: String?
    var notificationObject: [AnyHashable: Any]?
    var logStatement = ""
    var revisePI: Bool = false
    
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    ApplicationDelegate.shared.application(
        application,
        didFinishLaunchingWithOptions: launchOptions
    )
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
    window?.rootViewController = vc
    window?.makeKeyAndVisible()
    let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    print(paths[0])
    
    if let remoteNotification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as! [AnyHashable: Any]? {
      if (remoteNotification["email"] as? NSDictionary) != nil {
        notificationObject = remoteNotification
        logStatement = logStatement.appending("\n didFinishLaunchingWithOptions: remoteNotification[email]")
      }else {
        notificationObject = nil
        logStatement = logStatement.appending("\n didFinishLaunchingWithOptions: Nil")
      }
    }else {
      notificationObject = nil
      logStatement = logStatement.appending("\n didFinishLaunchingWithOptions: App Icon Launch")
    }
    
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

  func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {

      ApplicationDelegate.shared.application(
          app,
          open: url,
          sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
          annotation: options[UIApplication.OpenURLOptionsKey.annotation]
      )

  }


    // MARK: - Apple Push Notification Service Delegate methods
    
    func requestPushNotificationAccess() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                guard granted else { return }
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    guard settings.authorizationStatus == .authorized else { return }
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "notification_token")
        defaults.set(true, forKey: "device_enabled")
        defaults.synchronize()
        if let client = try? SafeClient(wrapping: CraftExchangeClient()) {
            let service = NotificationService.init(client: client)
            service.savePushNotificationToken(deviceId: UIDevice.current.identifierForVendor?.uuidString ?? "", token: token).bind(to: application, context: .global(qos: .background)) { _, responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                        print(json)
                    }
            }.dispose(in: self.bag)
        }
        debugPrint("Generated device token: \(token)")
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to Register device token for notification")
    }
    
    // MARK: - Remote Notification
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        /// Perform background fetch  when new notification is received
        logStatement = logStatement.appending("\n didReceiveRemoteNotification: \(userInfo)")
    }
}

