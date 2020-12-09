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
    @IBOutlet weak var changeLangButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
        self.viewModel.confirmPassword.bidirectionalBind(to: confirmPasswordField.reactive.text)
        self.navigationItem.rightBarButtonItem = roleBarButton()
        changeLangButton.isHidden = KeychainManager.standard.userRole == "Buyer" ? true : false
    }
    
    @IBAction func resetPasswordSelected(_ sender: Any) {
        self.viewModel.preformResetPassword?()
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
