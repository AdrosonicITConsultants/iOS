//
//  EnquiryGeneratedView.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol EnquiryGeneratedViewProtocol {
    func closeButtonSelected()
    func viewEnquiryButtonSelected(enquiryId: Int)
}

class EnquiryGeneratedView: UIView {
    @IBOutlet var enquiryCodeLabel: UILabel!
    @IBOutlet var closeBtn: UIButton!
    @IBOutlet var viewEnquiryBtn: RoundedButton!
    var delegate: EnquiryGeneratedViewProtocol?
    var enquiryId: Int?

    @IBAction func closeButtonSelected(_ sender: Any) {
      delegate?.closeButtonSelected()
    }
    
    @IBAction func viewEnquiryButtonSelected(_ sender: Any) {
        delegate?.viewEnquiryButtonSelected(enquiryId: enquiryId ?? 0)
    }
}
