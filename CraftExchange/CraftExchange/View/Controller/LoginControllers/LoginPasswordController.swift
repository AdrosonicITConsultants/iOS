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
  @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var changeLangButton: UIButton!
    
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
    registerBtn.setTitle("New user? Click here to register.".localized, for: .normal)
    changeLangButton.isHidden = KeychainManager.standard.userRole == "Buyer" ? true : false
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
    
  @IBAction func faqButtonSelected(_ sender: UIButton){
        didTapFAQButton(tag : sender.tag)
  }
    
    @IBAction func languageButtonSelected(_ sender: UIButton){
        showLanguagePickerAlert()
    }
}
