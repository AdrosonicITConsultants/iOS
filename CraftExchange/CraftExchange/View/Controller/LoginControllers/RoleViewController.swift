//
//  RoleViewController.swift
//  CraftExchange
//
//  Created by Preety Singh on 28/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import ReactiveKit
import UIKit

class RoleViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  @IBAction func artisanSelected(_ sender: Any) {
    KeychainManager.standard.userRole = "Artisan"
    KeychainManager.standard.userRoleId = 1
    showLogin()
  }
  
  @IBAction func buyerSelected(_ sender: Any) {
    KeychainManager.standard.userRole = "Buyer"
    KeychainManager.standard.userRoleId = 2
    showLogin()
  }
  
  func showLogin() {
    print(KeychainManager.standard.userRoleId as Any)
    do {
      let client = try SafeClient(wrapping: CraftExchangeClient())
      let controller = ValidateUserService(client: client).createScene()
      let navigationController = UINavigationController(rootViewController: controller)
      self.present(navigationController, animated: true, completion: nil)
    } catch let error {
      print("Unable to load view:\n\(error.localizedDescription)")
    }
  }
}
