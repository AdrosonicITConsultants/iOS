//
//  PartialRefundReceivedView.swift
//  CraftExchange
//
//  Created by Kalyan on 01/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol PartialRefundReceivedViewProtocol {
    func RefundCancelButtonSelected()
    func RefundNoButtonSelected()
    func RefundYesButtonSelected()
}

class PartialRefundReceivedView: UIView {

    @IBOutlet weak var RefundCancelButton: UIButton!
    @IBOutlet weak var confirmQuestion: UILabel!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var RefundNoButton: RoundedButton!
    @IBOutlet weak var RefundYesButton: RoundedButton!
     var delegate: PartialRefundReceivedViewProtocol?
    
    @IBAction func RefundCancelButtonSelected(_ sender: Any) {
        delegate?.RefundCancelButtonSelected()
    }
    
    @IBAction func RefundNoButtonSelected(_ sender: Any) {
        delegate?.RefundNoButtonSelected()
    }
    
    @IBAction func RefundYesButtonSelected(_ sender: Any) {
        delegate?.RefundYesButtonSelected()
    }

}
