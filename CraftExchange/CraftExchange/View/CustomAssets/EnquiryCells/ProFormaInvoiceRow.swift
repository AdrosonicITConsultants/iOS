//
//  ProFormaInvoiceRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 13/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol InvoiceButtonProtocol {
    func createSendInvoiceBtnSelected(tag: Int)
}

class ProFormaInvoiceRowView: Cell<String>, CellType {

    @IBOutlet weak var nextStepsLabel: UILabel!
    
    @IBOutlet weak var createSendInvoiceBtn: UIButton!
    
    var delegate: InvoiceButtonProtocol?
    
    @IBAction func createSendInvoiceBtnSelected(_ sender: Any) {
delegate?.createSendInvoiceBtnSelected(tag: tag)
       }
    public override func setup() {
        super.setup()
        createSendInvoiceBtn.addTarget(self, action: #selector(createSendInvoiceBtnSelected(_:)), for: .touchUpInside)

    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ProFormaInvoiceRow: Row<ProFormaInvoiceRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProFormaInvoiceRowView>(nibName: "ProFormaInvoiceRow")
    }
}




