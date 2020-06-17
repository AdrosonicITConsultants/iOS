//
//  RegisterArtisanController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class REGArtisanViewModel {
    var completeRegistration: (() -> Void)?
}

class RegisterArtisanController: UIViewController {
  
  lazy var viewModel = REGArtisanViewModel()
  var isTCAccepted = false
  @IBOutlet weak var completeButton: RoundedButton!
  @IBOutlet weak var checkboxButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func toggleCheckbox(_ sender: Any) {
    isTCAccepted = !isTCAccepted
    let img = isTCAccepted == true ? UIImage.init(systemName: "checkmark.square") : UIImage.init(systemName: "square")
    checkboxButton.setImage(img, for: .normal)
  }
  
  @IBAction func completeButtonSelected(_ sender: Any) {
    self.viewModel.completeRegistration?()
  }
}
