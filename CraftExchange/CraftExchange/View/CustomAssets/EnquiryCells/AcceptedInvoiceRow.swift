//
//  AcceptedInvoiceRow.swift
//  CraftExchange
//
//  Created by Kalyan on 30/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol AcceptedInvoiceRowProtocol {
    func viewInvoiceButtonSelected(tag: Int)
}

class AcceptedInvoiceRowView: Cell<String>, CellType {

      var delegate: AcceptedInvoiceRowProtocol?
    @IBOutlet weak var invoiceButton: UIButton!
    
    public override func setup() {
      super.setup()
      
      invoiceButton.addTarget(self, action: #selector(viewInvoiceButtonSelected(_:)), for: .touchUpInside)
       }

    
    public override func update() {
       super.update()
     }
 @IBAction func viewInvoiceButtonSelected(_ sender: Any) {
      delegate?.viewInvoiceButtonSelected(tag: tag)
    }
   
}

final class AcceptedInvoiceRow: Row<AcceptedInvoiceRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AcceptedInvoiceRowView>(nibName: "AcceptedInvoiceRow")
    }
   
    
}

