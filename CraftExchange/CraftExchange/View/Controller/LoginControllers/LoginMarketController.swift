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
    var goToRegister: (() -> Void)?
}
class LoginMarketController: UIViewController {
    @IBOutlet weak var loginButton: RoundedButton!
    @IBOutlet weak var usernameField: RoundedTextField!
    @IBOutlet weak var passwordField: RoundedTextField!
    var viewModel = LoginMarketViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.viewModel.username.bidirectionalBind(to: usernameField.reactive.text)
        self.viewModel.password.bidirectionalBind(to: passwordField.reactive.text)
        self.navigationItem.rightBarButtonItem = roleBarButton()
    }
    
    
    
    @IBAction func loginButtonSelected(_ sender: Any) {
        //        self.showLoading()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc1 = storyboard.instantiateViewController(withIdentifier: "MarketHomeController") as! MarketHomeController
        vc1.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(vc1, animated: true)
        
        
    }
    
}

