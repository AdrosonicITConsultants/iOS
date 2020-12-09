//
//  TransactionReceiptRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 07/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol paymentButtonProtocol {
    func paymentBtnSelected(tag: Int)
    func viewProformaInvoiceBtnSelected(tag: Int)
}

class TransactionReceiptRowView: Cell<String>, CellType {
    
    @IBOutlet weak var viewProformaInvoiceBtn: UIButton!
    @IBOutlet weak var uploadReceiptBtn: UIButton!
    @IBOutlet weak var invoiceImageView: UIImageView!
    
    var delegate: paymentButtonProtocol?
    
    @IBAction func paymentBtnSelected(_ sender: Any) {
        
        delegate?.paymentBtnSelected(tag: tag)
        
        print("uploadReceiptBtnSelected")
        
    }
    @IBAction func viewProformaInvoiceBtnSelected(_ sender: Any) {
        
        delegate?.viewProformaInvoiceBtnSelected(tag: tag)
        
        print("uploadReceiptBtnSelected")
        
    }
    
    public override func setup() {
        super.setup()
        uploadReceiptBtn.addTarget(self, action: #selector(paymentBtnSelected(_:)), for: .touchUpInside)
        viewProformaInvoiceBtn.addTarget(self, action: #selector(viewProformaInvoiceBtnSelected(_:)), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class TransactionReceiptRow: Row<TransactionReceiptRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<TransactionReceiptRowView>(nibName: "TransactionReceiptRow")
    }
}


