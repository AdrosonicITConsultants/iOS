//
//  RoundedButton.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = 1
            self.layer.cornerRadius = cornerRadius
            self.layer.borderColor = UIColor.black.cgColor
            //          self.backgroundColor = .black
            //          self.setTitleColor(.white, for: .normal)
        }
    }
    
    @IBInspectable var borderColour: UIColor = .black {
        didSet {
            self.layer.borderColor = borderColour.cgColor
        }
    }
}
