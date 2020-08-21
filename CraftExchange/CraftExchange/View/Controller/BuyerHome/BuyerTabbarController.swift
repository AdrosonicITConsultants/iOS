//
//  BuyerTabbarController.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class BuyerTabbarController: UITabBarController {
    let actionsManager = OfflineRequestManager.defaultManager
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.tabbar = self
    OfflineRequestManager.defaultManager.delegate = self
  }
}

extension BuyerTabbarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if self.selectedIndex == 2 {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = WishlistService(client: client).createScene()
                let nav = self.customizableViewControllers?[2] as! UINavigationController
                nav.setViewControllers([vc], animated: false)
            } catch let error {
              print("Unable to load view:\n\(error.localizedDescription)")
            }
        }
    }
}

extension BuyerTabbarController: OfflineRequestManagerDelegate {
    
    func offlineRequest(withDictionary dictionary: [String : Any]) -> OfflineRequest? {
        return OfflineProfileActionsRequest(dictionary: dictionary)
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, shouldAttemptRequest request: OfflineRequest) -> Bool {
        return true
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, didUpdateConnectionStatus connected: Bool) {
        
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, didFinishRequest request: OfflineRequest) {
        
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, requestDidFail request: OfflineRequest, withError error: Error) {
        
    }
}
