//
//  UnresolvedEscalationView.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol UnresolvedEscalationViewProtocol {
    func closeGenerateEnquirySelected()
    func generateNewEqSelected(eqId: Int)
}

class UnresolvedEscalationView: UIView {
    
    @IBOutlet var enquiryNumber: UILabel!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var artisanBrand: UILabel!
    @IBOutlet var buyerBrand: UILabel!
    @IBOutlet var concernLabel: UILabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var generateNewEqButton: UIButton!
    
    var delegate: UnresolvedEscalationViewProtocol?
    
    @IBAction func closeSelected(_ sender: Any) {
        delegate?.closeGenerateEnquirySelected()
    }
    
    @IBAction func createNewEqSelected(_ sender: Any) {
        delegate?.generateNewEqSelected(eqId: generateNewEqButton.tag)
    }
}
