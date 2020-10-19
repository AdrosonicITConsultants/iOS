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
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if KeychainManager.standard.userID != nil && KeychainManager.standard.userID != 0 {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            _ = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            return
        }
        let vc = storyboard.instantiateViewController(withIdentifier: "MarketHomeController") as! MarketHomeController
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }else {
//        let vc = storyboard.instantiateViewController(withIdentifier: "LoginMarketController") as! LoginMarketController
//        self.present(vc, animated: true, completion: nil)
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

