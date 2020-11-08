//
//  BuyerReviewConfirmView.swift
//  CraftExchange
//
//  Created by Kalyan on 07/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol BuyerReviewConfirmViewProtocol {
    func closeBuyerReviewConfirmSelected()
    func cancelBuyerReviewConfirmSelected()
    func confirmSendingBuyerReviewSelected()
}

class BuyerReviewConfirmView: UIView {

    @IBOutlet weak var closeBuyerReviewConfirm: UIButton!
    
    @IBOutlet weak var cancelBuyerReviewConfirm: UIButton!
    @IBOutlet weak var confirmSendingBuyerReview: RoundedButton!
    
    var delegate: BuyerReviewConfirmViewProtocol?
    
    @IBAction func closeBuyerReviewConfirmSelected(_ sender: Any) {
        delegate?.closeBuyerReviewConfirmSelected()
    }
    @IBAction func cancelBuyerReviewConfirmSelected(_ sender: Any) {
        delegate?.cancelBuyerReviewConfirmSelected()
    }
    
    @IBAction func confirmSendingBuyerReviewSelected(_ sender: Any) {
        delegate?.confirmSendingBuyerReviewSelected()
    }
    
}
