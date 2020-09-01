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
    func viewEnquiryButtonSelected()
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

    @IBAction func cancelButtonSelected(_ sender: Any) {
      delegate?.cancelButtonSelected()
    }
    
    @IBAction func viewEnquiryButtonSelected(_ sender: Any) {
      delegate?.viewEnquiryButtonSelected()
    }
    
    @IBAction func generateEnquiryButtonSelected(_ sender: Any) {
      delegate?.generateEnquiryButtonSelected(prodId: productId ?? 0)
    }
}
