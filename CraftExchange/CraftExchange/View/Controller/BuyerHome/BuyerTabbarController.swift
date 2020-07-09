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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    appDelegate?.tabbar = self
  }
  
  
}
