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
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.marketingTabbar = self
  }

}

extension MarketingTabbarController {
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        if item.title == "Team" {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = MarketingTeammateService(client: client).createScene()
                let nav = self.customizableViewControllers?[4] as! UINavigationController
                nav.setViewControllers([vc], animated: false)
            } catch let error {
              print("Unable to load view:\n\(error.localizedDescription)")
            }
        }
        else if item.title == "User" {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = AdminUserService(client: client).createScene()
                let nav = self.customizableViewControllers?[1] as! UINavigationController
                nav.setViewControllers([vc], animated: false)
            } catch let error {
              print("Unable to load view:\n\(error.localizedDescription)")
            }
        }else if item.title == "Products" {
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
