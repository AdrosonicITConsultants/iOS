//
//  RegisterBuyerController.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import ReactiveKit
import UIKit

class REGBuyerViewModel {
    var websiteLink = Observable<String?>(nil)
    var socialMediaLink = Observable<String?>(nil)
    var completeRegistration: (() -> Void)?
}

class RegisterBuyerController: UIViewController {
  
  lazy var viewModel = REGBuyerViewModel()

  @IBOutlet weak var websiteLinkField: RoundedTextField!
  @IBOutlet weak var mediaLinkField: RoundedTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.websiteLink.bidirectionalBind(to: websiteLinkField.reactive.text)
    self.viewModel.socialMediaLink.bidirectionalBind(to: mediaLinkField.reactive.text)
  }
  
  @IBAction func completeButtonSelected(_ sender: Any) {
    self.viewModel.completeRegistration?()
  }
}
