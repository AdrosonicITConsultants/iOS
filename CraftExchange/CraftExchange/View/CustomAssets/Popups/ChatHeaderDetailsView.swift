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
    override func layoutSubviews() {
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 4
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0 , height:2)
    }
    
}
