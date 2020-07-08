//
//  REGValidateArtisanController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class ValidationArtisanViewModel {
    var weaverId = Observable<String?>("")
    var performValidation: (() -> Void)?
}

class REGValidateArtisanController: UIViewController {
  
  lazy var viewModel = ValidationArtisanViewModel()
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  @IBOutlet weak var nextButton: RoundedButton!
  @IBOutlet weak var weaverIdField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.weaverId.bidirectionalBind(to: weaverIdField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
    
    override func viewDidAppear(_ animated: Bool) {
        weaverIdField.text = appDelegate?.registerUser?.weaverId
        self.viewModel.weaverId.value = weaverIdField.text
    }
  
  @IBAction func nextButtonSelected(_ sender: Any) {
    self.viewModel.performValidation?()
  }
}
