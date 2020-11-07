//
//  ForgotPasswordController.swift
//  CraftExchange
//
//  Created by Preety Singh on 31/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class ForgotPassworViewModel {
    var username = Observable<String?>("")
    var otp = Observable<String?>("")
    var sendOTP: (() -> Void)?
    var validateOTP: (() -> Void)?
}

class ForgotPasswordController: UIViewController {
  
  
  lazy var viewModel = ForgotPassworViewModel()
  
  @IBOutlet weak var sendOTPButton: RoundedButton!
  @IBOutlet weak var nextButton: RoundedButton!
  @IBOutlet weak var usernameField: RoundedTextField!
  @IBOutlet weak var otpField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    
    self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
    self.viewModel.otp.bidirectionalBind(to: otpField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func nextButtonSelected(_ sender: Any) {
      self.viewModel.validateOTP?()
    }
  
  @IBAction func sendOTPSelected(_ sender: Any) {
    self.viewModel.sendOTP?()
  }
    
  @IBAction func faqButtonSelected(_ sender: UIButton){
        didTapFAQButton(tag: sender.tag)
  }
    
    @IBAction func languageButtonSelected(_ sender: UIButton){
        showLanguagePickerAlert()
    }
    
}
