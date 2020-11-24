//
//  MarketingTabbarController.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class MarketingTabbarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension MarketingTabbarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.title == "Products" {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = AdminProductCatalogueService(client: client).createAdminProductCatalogue()
                let nav = self.customizableViewControllers?[2] as! UINavigationController
                nav.setViewControllers([vc], animated: false)
            } catch let error {
                print("Unable to load view:\n\(error.localizedDescription)")
            }
        }
    }
}
