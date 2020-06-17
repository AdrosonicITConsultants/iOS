//
//  REGNewUserPasswordController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class REGNewUserPasswordViewModel {
    var password = Observable<String?>("")
    var confirmPassword = Observable<String?>("")
}

class REGNewUserPasswordController: UIViewController {
  
  lazy var viewModel = REGNewUserPasswordViewModel()

  @IBOutlet weak var confirmButton: RoundedButton!
  @IBOutlet weak var passwordField: RoundedTextField!
  @IBOutlet weak var confirmPasswordField: RoundedTextField!
  var weaverId: String?
  var validatedEmailId: String?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
    self.viewModel.confirmPassword.bidirectionalBind(to: confirmPasswordField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func confirmPasswordSelected(_ sender: Any) {
    if let email = validatedEmailId, let password = viewModel.password.value, let confirmPass = viewModel.confirmPassword.value {
      if password == confirmPass {
        if KeychainManager.standard.userRole == "Artisan" {
          do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let controller = REGArtisanInfoInputService(client: client).createScene(weaverId: weaverId!, email: email, password: password)
            self.navigationController?.pushViewController(controller, animated: true)
          } catch let error {
            print("Unable to load view:\n\(error.localizedDescription)")
          }
        }else {
          do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let controller = REGBuyerPersonalInfoService(client: client).createScene(email: email, password: password)
            self.navigationController?.pushViewController(controller, animated: true)
          } catch let error {
            print("Unable to load view:\n\(error.localizedDescription)")
          }
        }
      }else {
          self.alert("Password & Confirm password mismatch.")
        }
      }else {
        self.alert("Please enter password & confirm your password")
      }
  }
}

