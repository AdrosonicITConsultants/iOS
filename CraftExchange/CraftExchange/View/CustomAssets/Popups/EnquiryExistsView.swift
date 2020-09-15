//
//  EnquiryExistsView.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol EnquiryExistsViewProtocol {
    func cancelButtonSelected()
    func viewEnquiryButtonSelected(eqId: Int)
    func generateEnquiryButtonSelected(prodId: Int)
}

class EnquiryExistsView: UIView {
    @IBOutlet var productLabel: UILabel!
    @IBOutlet var enquiryIdLabel: UILabel!
    @IBOutlet var cancelBtn: RoundedButton!
    @IBOutlet var viewEnquiryBtn: RoundedButton!
    @IBOutlet var generateEnquiryBtn: RoundedButton!
    var delegate: EnquiryExistsViewProtocol?
    var productId: Int?
    var enquiryId: Int?

    @IBAction func cancelButtonSelected(_ sender: Any) {
      delegate?.cancelButtonSelected()
    }
    
    @IBAction func viewEnquiryButtonSelected(_ sender: Any) {
      delegate?.viewEnquiryButtonSelected(eqId: enquiryId ?? 0)
    }
    
    @IBAction func generateEnquiryButtonSelected(_ sender: Any) {
      delegate?.generateEnquiryButtonSelected(prodId: productId ?? 0)
    }
}
