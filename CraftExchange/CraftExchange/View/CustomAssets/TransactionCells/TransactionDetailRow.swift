//
//  TransactionDetailRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 06/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

@objc protocol TransactionListProtocol {
    @objc optional func viewTransactionReceipt(tag: Int)
}

class TransactionDetailRow: Cell<String>, CellType {
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var invoiceButton: UIButton!
    let invoiceStateArray = [1,2,3,4,5,12,13]
    var delegate: TransactionListProtocol?
    
    func configure(_ transaction: TransactionObject) {
        amountLabel.text = transaction.totalAmount == 0 ? "₹ \(transaction.paidAmount)" : "₹ \(transaction.totalAmount)"
        if let date = transaction.modifiedOn {
            dateLabel.text = Date().ttceISOString(isoDate: date)
        }
        if invoiceStateArray.contains(transaction.accomplishedStatus) {
            invoiceButton.setImage(UIImage.init(named: "invoice"), for: .normal)
            invoiceButton.setTitle("View Invoice", for: .normal)
        }else {
            invoiceButton.setImage(UIImage.init(named: "receipt"), for: .normal)
            invoiceButton.setTitle("View Receipt", for: .normal)
        }
    }
    
    @IBAction func invoiceSelected(_ sender: Any) {
        let btn = sender as! UIButton
        delegate?.viewTransactionReceipt?(tag: btn.tag)
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class TransactionDetailRowView: Row<TransactionDetailRow>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<TransactionDetailRow>(nibName: "TransactionDetailRow")
    }
}
