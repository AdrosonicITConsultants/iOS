//
//  ProfileImageRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 12/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class ProfileImageRowView: Cell<String>, CellType {

    @IBOutlet var actionButton: UIButton!
    var options: [String]?
    var delegate: UIViewController!
    var selectedVal: String?
    
  public override func setup() {
    super.setup()
    actionButton.addTarget(self, action: #selector(actionButtonSelected(_:)), for: .touchUpInside)
    actionButton.imageView?.layer.cornerRadius = 80
  }

  public override func update() {
    super.update()
  }
  
  @IBAction func actionButtonSelected(_ sender: Any) {

    let alert = UIAlertController.init(title: "Please Select:".localized, message: "Options:".localized, preferredStyle: .actionSheet)
    let action1 = UIAlertAction.init(title: "Camera".localized, style: .default) { (action) in
        let imagePicker =  UIImagePickerController()
        imagePicker.delegate = self.delegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        imagePicker.sourceType = .camera
        self.delegate?.present(imagePicker, animated: true, completion: nil)
    }
    alert.addAction(action1)
    let action2 = UIAlertAction.init(title: "Gallery".localized, style: .default) { (action) in
      let imagePicker =  UIImagePickerController()
      imagePicker.delegate = self.delegate as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
      imagePicker.sourceType = .photoLibrary
      self.delegate?.present(imagePicker, animated: true, completion: nil)
    }
    alert.addAction(action2)
    let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
    }
    alert.addAction(action)
    delegate?.present(alert, animated: true, completion: nil)
  }
  
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ProfileImageRow: Row<ProfileImageRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProfileImageRowView>(nibName: "ProfileImageRow")
    }
}

