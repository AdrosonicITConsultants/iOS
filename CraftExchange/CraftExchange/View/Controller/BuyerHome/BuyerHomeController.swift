//
//  BuyerHomeController.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class BuyerHomeController: UIViewController {
  
  @IBOutlet weak var loggedInUserName: UILabel!
  @IBOutlet weak var buyerCover: UIImageView!
  
  @IBOutlet weak var selfDesignView: UIView!
  @IBOutlet weak var antaranDesignView: UIView!
  
  @IBOutlet weak var customDesignButton: RoundedButton!
  
  override func viewDidLoad() {

    selfDesignView.dropShadow()
    antaranDesignView.dropShadow()
    self.selfDesignView.layer.cornerRadius = 5
    self.antaranDesignView.layer.cornerRadius = 5
    
    loggedInUserName.text = "Hi \(KeychainManager.standard.username ?? "")"
    
    self.setupSideMenu()
    
    super.viewDidLoad()
  }
}
