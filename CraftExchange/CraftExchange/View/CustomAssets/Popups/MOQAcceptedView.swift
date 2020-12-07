//
//  MOQAcceptedView.swift
//  CraftExchange
//
//  Created by Kalyan on 28/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol MOQAcceptedViewProtocol {
    func enquiryChatButtonSelected()
    func okButtonSelected()
}

class MOQAcceptedView: UIView {
    
    @IBOutlet weak var brandClusterText: UILabel!
    @IBOutlet weak var moqText: UILabel!
    @IBOutlet weak var ETADaysText: UILabel!
    @IBOutlet weak var pricePerUnitText: UILabel!
    @IBOutlet weak var goToEnquiryChat: RoundedButton!
    @IBOutlet weak var okButton: RoundedButton!
    
    var delegate: MOQAcceptedViewProtocol?
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    @IBAction func enquiryChatButtonSelected(_ sender: Any) {
        delegate?.enquiryChatButtonSelected()
    }
    
    @IBAction func okButtonSelected(_ sender: Any) {
        delegate?.okButtonSelected()
    }
    
}
