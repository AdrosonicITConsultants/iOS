//
//  DefaultViewController.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import ReactiveKit
import UIKit

class DefaultViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if KeychainManager.standard.userID != nil && KeychainManager.standard.userID != 0 {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            _ = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            return
        }
//        let storyboard = UIStoryboard(name: "MarketingTabbar", bundle: nil)
//        let tab = storyboard.instantiateViewController(withIdentifier: "MarketingTabbarController") as! MarketingTabbarController
//        tab.modalPresentationStyle = .fullScreen
//        self.present(tab, animated: true, completion: nil)
        let controller = AdminHomeScreenService(client: client).createScene()
        self.present(controller, animated: true, completion: nil)
    }else {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            _ = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            return
        }
        let controller = LoginUserService(client: client).createScene()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
  }
}

