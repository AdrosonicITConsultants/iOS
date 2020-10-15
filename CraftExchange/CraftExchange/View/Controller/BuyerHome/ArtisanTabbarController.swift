//
//  ArtisanTabbarController.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class ArtisanTabbarController: UITabBarController {
    let actionsManager = OfflineRequestManager.defaultManager
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.artisanTabbar = self
    OfflineRequestManager.defaultManager.delegate = self
  }
}

extension ArtisanTabbarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Enquiries" {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = EnquiryListService(client: client).createScene()
                let nav = self.customizableViewControllers?[1] as! UINavigationController
                nav.setViewControllers([vc], animated: false)
            } catch let error {
              print("Unable to load view:\n\(error.localizedDescription)")
            }
        }else if item.title == "Orders" {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = OrderListService(client: client).createScene()
                let nav = self.customizableViewControllers?[1] as! UINavigationController
                nav.setViewControllers([vc], animated: false)
            } catch let error {
              print("Unable to load view:\n\(error.localizedDescription)")
            }
        }
    }
}

extension ArtisanTabbarController: OfflineRequestManagerDelegate {
    
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

