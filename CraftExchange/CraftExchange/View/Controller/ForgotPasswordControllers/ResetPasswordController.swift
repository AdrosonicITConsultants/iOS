//
//  ResetPasswordController.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class ResetPasswordViewModel {
    var username = Observable<String?>("")
    var password = Observable<String?>("")
    var confirmPassword = Observable<String?>("")
    var preformResetPassword: (() -> Void)?
}

class ResetPasswordController: UIViewController {
  
  lazy var viewModel = ResetPasswordViewModel()

  @IBOutlet weak var resetButton: RoundedButton!
  @IBOutlet weak var passwordField: RoundedTextField!
  @IBOutlet weak var confirmPasswordField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
    self.viewModel.confirmPassword.bidirectionalBind(to: confirmPasswordField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func resetPasswordSelected(_ sender: Any) {
    self.viewModel.preformResetPassword?()
  }
}
