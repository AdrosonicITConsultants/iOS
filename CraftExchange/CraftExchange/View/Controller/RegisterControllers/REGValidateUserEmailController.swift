//
//  REGValidateUserEmailController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class REGValidateUserEmailViewModel {
    var username = Observable<String?>("")
    var otp = Observable<String?>("")
    var sendOTP: (() -> Void)?
    var validateOTP: (() -> Void)?
}

class REGValidateUserEmailController: UIViewController {
  
  lazy var viewModel = REGValidateUserEmailViewModel()

  @IBOutlet weak var sendOtpButton: RoundedButton!
  @IBOutlet weak var nextButton: RoundedButton!
  @IBOutlet weak var usernameField: RoundedTextField!
  @IBOutlet weak var otpField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.navigationItem.rightBarButtonItem = roleBarButton()
    self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
    self.viewModel.otp.bidirectionalBind(to: otpField.reactive.text)
  }
  
  @IBAction func nextButtonSelected(_ sender: Any) {
      self.viewModel.validateOTP?()
    }
  
  @IBAction func sendOTPSelected(_ sender: Any) {
    self.viewModel.sendOTP?()
  }
}
