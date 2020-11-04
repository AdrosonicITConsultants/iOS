//
//  PwdResetSuccessfulController.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Bond
import ReactiveKit
import UIKit

class PwdResetSuccessfulController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func showLoginSelected(_sender: Any) {
    do {
      let client = try SafeClient(wrapping: CraftExchangeClient())
      let controller = ValidateUserService(client: client).createScene()
      let navigationController = UINavigationController(rootViewController: controller)
      self.present(navigationController, animated: true, completion: nil)
    } catch let error {
      print("Unable to load view:\n\(error.localizedDescription)")
    }
  }

  @IBAction func faqButtonSelected(_ sender: UIButton){
        didTapFAQButton(tag: sender.tag)
  }
}
