//
//  CloseOrderView.swift
//  CraftExchange
//
//  Created by Kalyan on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol CloseOrderViewProtocol {
    func closeOrderCancelButtonSelected()
    func closeOrderNoButtonSelected()
    func closeOrderYesButtonSelected()
}

class CloseOrderView: UIView {

    @IBOutlet weak var closeOrderCancelButton: UIButton!
    @IBOutlet weak var confirmStatement: UILabel!
    @IBOutlet weak var enquiryCode: UILabel!
    
    @IBOutlet weak var closeOrderNoButton: RoundedButton!
    
    @IBOutlet weak var closeOrderYesButton: RoundedButton!
    var delegate: CloseOrderViewProtocol?

    @IBAction func closeOrderCancelButtonSelected(_ sender: Any) {
        delegate?.closeOrderCancelButtonSelected()
    }
    
    @IBAction func closeOrderNoButtonSelected(_ sender: Any) {
        delegate?.closeOrderNoButtonSelected()
    }
    
    @IBAction func closeOrderYesButtonSelected(_ sender: Any) {
        delegate?.closeOrderYesButtonSelected()
    }
}
