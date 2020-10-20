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
        let controller = LoginUserService(client: client).createScene()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    } catch let error {
        print("Unable to load view:\n\(error.localizedDescription)")
    }
  }
}
