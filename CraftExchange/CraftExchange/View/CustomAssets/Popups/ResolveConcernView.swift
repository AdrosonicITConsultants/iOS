//
//  ResolveConcernView.swift
//  CraftExchange
//
//  Created by Kalyan on 27/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

protocol ResolveConcernViewProtocol {
    func closeButtonSelected()
    func resolvebuttonSelected(eqId: Int)
}

class ResolveConcernView: UIView {

    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var totalText: UILabel!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var concern: UILabel!
    @IBOutlet weak var resolvebutton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegate: ResolveConcernViewProtocol?
    @IBAction func resolveButtonSelected(_ sender: Any) {
        delegate?.resolvebuttonSelected(eqId: resolvebutton.tag)
    }
    @IBAction func closeButtonSelected(_ sender: Any) {
        delegate?.closeButtonSelected()
    }
    
}
