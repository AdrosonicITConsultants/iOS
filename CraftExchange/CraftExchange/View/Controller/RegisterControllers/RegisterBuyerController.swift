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
  var isTCAccepted = false
  @IBOutlet weak var checkboxButton: UIButton!
  @IBOutlet weak var websiteLinkField: RoundedTextField!
  @IBOutlet weak var mediaLinkField: RoundedTextField!
  let appDelegate = UIApplication.shared.delegate as? AppDelegate
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.viewModel.websiteLink.bidirectionalBind(to: websiteLinkField.reactive.text)
    self.viewModel.socialMediaLink.bidirectionalBind(to: mediaLinkField.reactive.text)
    self.navigationItem.rightBarButtonItem = roleBarButton()
    websiteLinkField.text = appDelegate?.registerUser?.websiteLink
    mediaLinkField.text = appDelegate?.registerUser?.socialMediaLink
    self.viewModel.websiteLink.value = websiteLinkField.text
    self.viewModel.socialMediaLink.value = mediaLinkField.text
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
