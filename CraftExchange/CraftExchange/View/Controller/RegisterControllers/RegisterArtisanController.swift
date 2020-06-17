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

  @IBOutlet weak var completeButton: RoundedButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.rightBarButtonItem = roleBarButton()
  }
  
  @IBAction func completeButtonSelected(_ sender: Any) {
    self.viewModel.completeRegistration?()
  }
}
