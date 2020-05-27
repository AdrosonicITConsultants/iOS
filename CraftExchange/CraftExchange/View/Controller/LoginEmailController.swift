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
}

class LoginEmailController: UIViewController {
  
  lazy var viewModel = ValidationViewModel()

  @IBOutlet weak var nextButton: RoundedButton!
  @IBOutlet weak var usernameField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
  }
  
  @IBAction func nextButtonSelected(_ sender: Any) {
    self.viewModel.performValidation?()
//    self.performSegue(withIdentifier: "showPasswordScreenSegue", sender: self)
  }
}
