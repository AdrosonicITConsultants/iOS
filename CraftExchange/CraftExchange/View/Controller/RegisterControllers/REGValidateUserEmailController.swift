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
    @IBOutlet weak var changeLangButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationItem.rightBarButtonItem = roleBarButton()
        self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
        self.viewModel.otp.bidirectionalBind(to: otpField.reactive.text)
        changeLangButton.isHidden = KeychainManager.standard.userRole == "Buyer" ? true : false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        usernameField.text = appDelegate?.registerUser?.email
        self.viewModel.username.value = usernameField.text
    }
    
    @IBAction func nextButtonSelected(_ sender: Any) {
        usernameField.resignFirstResponder()
        otpField.resignFirstResponder()
        self.viewModel.validateOTP?()
    }
    
    @IBAction func sendOTPSelected(_ sender: Any) {
        usernameField.resignFirstResponder()
        otpField.resignFirstResponder()
        self.viewModel.sendOTP?()
    }
    
    @IBAction func faqButtonSelected(_ sender: UIButton){
        didTapFAQButton(tag: sender.tag)
    }
    
    @IBAction func languageButtonSelected(_ sender: UIButton){
        showLanguagePickerAlert()
    }
    @IBAction func reachOutToUsSelected(_ sender: Any) {
        alert("For any query","please write to us at craftxchange.tatatrusts@gmail.com" )
    }
    
}
