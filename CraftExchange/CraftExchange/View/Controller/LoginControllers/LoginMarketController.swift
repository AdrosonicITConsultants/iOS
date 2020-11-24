//
//  LoginMarketController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 09/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class LoginMarketViewModel {
    var username = Observable<String?>(nil)
    var password = Observable<String?>(nil)
    var performAuthentication: (() -> Void)?
    var goToForgotPassword: (() -> Void)?
    var goToLogin: (() -> Void)?
}

class LoginMarketController: UIViewController {
    
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var usernameField: RoundedTextField!
    @IBOutlet weak var passwordField: RoundedTextField!
    var viewModel = LoginMarketViewModel()
    var viewWillAppear: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
        self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
        self.navigationItem.rightBarButtonItem = roleBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    @IBAction func loginButtonSelected(_ sender: Any) {
        self.viewModel.performAuthentication?()
    }
    
    @IBAction func forgotPasswordSelected(_ sender: Any) {
      self.viewModel.goToForgotPassword?()
    }
}

