//
//  LoginEmailScreen.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class ValidationViewModel {
  var username = Observable<String?>("")
  var performValidation: (() -> Void)?
  var goToRegister: (() -> Void)?
}

class LoginEmailController: UIViewController {
  
  lazy var viewModel = ValidationViewModel()

  @IBOutlet weak var nextButton: RoundedButton!
  @IBOutlet weak var usernameField: RoundedTextField!
    @IBOutlet weak var registerBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
    registerBtn.setTitle("New user? Click here to register.".localized, for: .normal)
  }
  
  @IBAction func nextButtonSelected(_ sender: Any) {
    self.viewModel.performValidation?()
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
