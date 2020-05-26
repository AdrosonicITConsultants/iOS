//
//  LoginEmailScreen.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class LoginEmailController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBOutlet weak var nextButton: RoundedButton!
  
  @IBAction func nextButtonSelected(_ sender: Any) {
    self.performSegue(withIdentifier: "showPasswordScreenSegue", sender: self)
  }
}
