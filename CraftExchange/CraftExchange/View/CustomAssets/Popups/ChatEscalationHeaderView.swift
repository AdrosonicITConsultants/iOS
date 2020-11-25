//
//  ChatEscalationHeaderView.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 10/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit

protocol ChatEscalationHeaderViewProtocol {
    func escalationButtonSelected2()
}

class ChatEscalationHeaderView: UIView {
    
    @IBOutlet var enquiryNumber: UILabel!
    @IBOutlet var CRView: UIButton!
    @IBOutlet var escalationButton: UIButton!
    
    var delegate: ChatEscalationHeaderViewProtocol?
    
    @IBAction func escalationButtonSelected(_ sender: Any) {
        delegate?.escalationButtonSelected2()
    }
}
