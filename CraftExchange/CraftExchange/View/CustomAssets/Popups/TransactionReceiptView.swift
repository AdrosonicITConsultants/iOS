//
//  TransactionReceiptView.swift
//  CraftExchange
//
//  Created by Kalyan on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit

protocol TransactionReceiptViewProtocol {
    func cancelBtnSelected()
}

class TransactionReceiptView: UIView {

    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var receiptImage: UIImageView!
    
    var delegate: TransactionReceiptViewProtocol?
    
    @IBAction func cancelButtonSelected(_ sender: Any) {
        delegate?.cancelBtnSelected()
    }

}

