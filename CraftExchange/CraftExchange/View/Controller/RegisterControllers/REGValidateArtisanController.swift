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

  @IBOutlet weak var nextButton: RoundedButton!
  @IBOutlet weak var weaverIdField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    self.viewModel.weaverId.bidirectionalBind(to: weaverIdField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func nextButtonSelected(_ sender: Any) {
    self.viewModel.performValidation?()
  }
}
