//
//  LoginPasswordController.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class LoginViewModel {
  var username = Observable<String?>("")
  var password = Observable<String?>("")
  var performAuthentication: (() -> Void)?
  var goToForgotPassword: (() -> Void)?
  var goToRegister: (() -> Void)?
}

class LoginPasswordController: UIViewController {
  
  lazy var viewModel = LoginViewModel()
  @IBOutlet weak var loginButton: RoundedButton!
  @IBOutlet weak var passwordField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func loginButtonSelected(_ sender: Any) {
    self.viewModel.performAuthentication?()
  }
  
  @IBAction func forgotPasswordSelected(_ sender: Any) {
    self.viewModel.goToForgotPassword?()
  }
  
  @IBAction func registerSelected(_ sender: Any) {
    self.viewModel.goToRegister?()
  }
}
