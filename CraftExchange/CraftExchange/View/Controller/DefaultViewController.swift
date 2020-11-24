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
            //        let nav = tab.customizableViewControllers?.first as! UINavigationController
            //        let vc = nav.topViewController as! MarketHomeController
            //  self.present(tab, animated: true, completion: nil)
            let controller = HomeScreenService(client: client).createMarketingHomeScene()
            self.present(controller, animated: true, completion: nil)
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

