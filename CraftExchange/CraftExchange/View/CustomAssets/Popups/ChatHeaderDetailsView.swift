//
//  ChatHeaderDetailsView.swift
//  CraftExchange
//
//  Created by Kalyan on 20/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation

protocol ChatHeaderDetailsViewProtocol {
    func goToEnquiryButtonSelected()
    func closeDetailsButtonSelected()
}

class ChatHeaderDetailsView: UIView {

    @IBOutlet weak var enquiryStartedOn: UILabel!
    @IBOutlet weak var convertedToOrderOn: UILabel!
    @IBOutlet weak var lastUpdatedOn: UILabel!
    @IBOutlet weak var productType: UILabel!
    @IBOutlet weak var orderAmount: UILabel!
    @IBOutlet weak var GoToEnquiryButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegate: ChatHeaderDetailsViewProtocol?
    
    @IBAction func goToEnquiryButtonSelected(_ sender: Any) {
        delegate?.goToEnquiryButtonSelected()
    }
    
    @IBAction func closeDetailsButtonSelected(_ sender: Any) {
        delegate?.closeDetailsButtonSelected()
    }
    
}
