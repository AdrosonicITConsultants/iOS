//
//  RoundedTextField.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import ReactiveKit

@IBDesignable
class RoundedTextField: UITextField, UITextFieldDelegate {

    // Provides left padding for images
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var textRect = super.leftViewRect(forBounds: bounds)
        textRect.origin.x += leftPadding
        return textRect
    }
  
    @IBInspectable var leftImage: UIImage? {
        didSet {
            updateView()
        }
    }
  
    @IBInspectable var rightImage: UIImage? {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var leftPadding: CGFloat = 0
    @IBInspectable var maxLength: Int = 500

    @IBInspectable var color: UIColor = UIColor.black {
        didSet {
            updateView()
        }
    }

    func updateView() {
        if let image = leftImage {
            leftViewMode = UITextField.ViewMode.always
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            imageView.tintColor = color
            leftView = imageView
        } else if let image = rightImage {
            rightViewMode = UITextField.ViewMode.always
            let button = UIButton.init(type: .custom)
            button.imageEdgeInsets = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 2)
            button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
            button.setImage(image, for: .normal)
            button.tag = 111
            button.tintColor = color
            button.addTarget(self, action: #selector(togglePasswordDisplay(_:)), for: .touchUpInside)
            rightView = button
        }
        else {
          let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
          leftView = paddingView
          leftViewMode = .always
        }
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 21
        self.frame.size.height = 40
        // Placeholder text color
        attributedPlaceholder = NSAttributedString(string: placeholder != nil ?  placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: color])
    }
  
  @objc func togglePasswordDisplay(_ sender: UIButton) {
    self.isSecureTextEntry = !self.isSecureTextEntry
    let button = self.viewWithTag(111) as! UIButton
    if isSecureTextEntry == true {
      button.setImage(UIImage.init(systemName: "eye"), for: .normal)
    }else {
      button.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
    }
  }
    
    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        let typeCasteToStringFirst = self.text as NSString?
        if let newRange = self.selectedRange {
            let newString = typeCasteToStringFirst?.replacingCharacters(in: newRange, with: text)
            return newString?.count ?? 0 <= maxLength
        }
        return true
    }

}

extension UITextInput {
    var selectedRange: NSRange? {
        guard let range = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: range.start)
        let length = offset(from: range.start, to: range.end)
        return NSRange(location: location, length: length)
    }
}
