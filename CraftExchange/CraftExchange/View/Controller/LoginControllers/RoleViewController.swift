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

    @IBOutlet weak var langButton: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    langButton.setTitle("  Change Language".localized, for: .normal)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if KeychainManager.standard.userID != nil && KeychainManager.standard.userID != 0 {
        guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
            _ = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
            return
        }
        if KeychainManager.standard.userRoleId == 1 {
            let controller = HomeScreenService(client: client).createScene()
            self.present(controller, animated: true, completion: nil)
        }else {
            let controller = HomeScreenService(client: client).createBuyerScene()
            self.present(controller, animated: true, completion: nil)
        }
    }
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

  @IBAction func faqButtonSelected(_ sender: UIButton) {
    didTapFAQButton(tag: sender.tag)
  }
    
  @IBAction func changeLangSelected(_ sender: UIButton) {
    showLanguagePickerAlert()
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
