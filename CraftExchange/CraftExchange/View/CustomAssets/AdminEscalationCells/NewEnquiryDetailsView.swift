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
    func chooseArtisanSelected(eqId: Int)
    func viewProductDetailSelected(prodId: Int)
}

class NewEnquiryDetailsView: UIView {
    
    @IBOutlet var enquiryNumber: UILabel!
    @IBOutlet var viewProductButton: UIButton!
    @IBOutlet var chooseArtisanButton: UIButton!
    
    var delegate: NewEnquiryDetailsViewProtocol?
    
    @IBAction func chooseArtisanSelected(_ sender: Any) {
        delegate?.chooseArtisanSelected(eqId: chooseArtisanButton.tag)
    }
    
    @IBAction func viewProductDetailSelected(_ sender: Any) {
        delegate?.viewProductDetailSelected(prodId: viewProductButton.tag)
    }
}
