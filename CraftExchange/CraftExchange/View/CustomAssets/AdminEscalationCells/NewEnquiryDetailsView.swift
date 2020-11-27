//
//  NewEnquiryDetailsView.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol NewEnquiryDetailsViewProtocol {
    func chooseArtisanSelected(eqId: Int, enquiryCode: String?)
    func viewProductDetailSelected(isCustom: Bool, prodId: Int, enquiryCode: String?)
    func closeRedirectButtonSelected()
}

class NewEnquiryDetailsView: UIView {
    
    @IBOutlet var enquiryNumber: UILabel!
    @IBOutlet var viewProductButton: UIButton!
    @IBOutlet var chooseArtisanButton: UIButton!
    
    @IBOutlet weak var closeButton: UIButton!
    var delegate: NewEnquiryDetailsViewProtocol?
    var isCustom = false
    var enquiryCode: String?
    
    @IBAction func chooseArtisanSelected(_ sender: Any) {
        delegate?.chooseArtisanSelected(eqId: chooseArtisanButton.tag, enquiryCode: enquiryCode)
    }
    @IBAction func closeButtonSelected(_ sender: Any) {
        delegate?.closeRedirectButtonSelected()
    }
    
    @IBAction func viewProductDetailSelected(_ sender: Any) {
        delegate?.viewProductDetailSelected(isCustom: isCustom , prodId: viewProductButton.tag, enquiryCode: enquiryCode)
    }
}
