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
//    self.dismiss(animated: true) {
//      let storyboard = UIStoryboard(name: "Main", bundle: nil)
//      let vc = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
//      let appDelegate = UIApplication.shared.delegate as? AppDelegate
//      appDelegate?.window?.rootViewController = vc
//      appDelegate?.window?.makeKeyAndVisible()
//    }
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
