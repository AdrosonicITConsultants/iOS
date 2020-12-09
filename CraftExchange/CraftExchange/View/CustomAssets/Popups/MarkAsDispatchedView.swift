//
//  MarkAsDispatchedView.swift
//  CraftExchange
//
//  Created by Kalyan on 01/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol MarkAsDispatchedViewProtocol {
    func MarkAsDispatchedButtonSelected()
    func MarkAsDipatchedCloseButtonSelected()
}

class MarkAsDispatchedView: UIView {
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    @IBOutlet weak var MarkAsDispatchedButton: UIButton!
    var delegate:MarkAsDispatchedViewProtocol?
    @IBOutlet weak var MarkAsDipatchedCloseButton: UIButton!
    
    @IBAction func MarkAsDispatchedButtonSelected(_ sender: Any) {
        delegate?.MarkAsDispatchedButtonSelected()
    }
    
    @IBAction func MarkAsDipatchedCloseButtonSelected(_ sender: Any) {
        delegate?.MarkAsDipatchedCloseButtonSelected()
    }
    
}
