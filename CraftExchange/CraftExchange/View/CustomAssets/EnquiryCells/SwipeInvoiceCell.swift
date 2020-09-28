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

protocol SwipeButtonProtocol {
    func swipeInvoiceBtnSelected(tag: Int)
}

class SwipeInvoiceRowView: Cell<String>, CellType {

    @IBOutlet weak var savePIBtn: UIButton!
    
    
    var delegate: SwipeButtonProtocol?

    @IBAction func swipeInvoiceBtnSelected(_ sender: Any) {
        delegate?.swipeInvoiceBtnSelected(tag: tag)
          print("...................................")
    }
   
    public override func setup() {
        super.setup()
        savePIBtn.addTarget(self, action: #selector(swipeInvoiceBtnSelected(_:)), for: .touchUpInside)
        
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class SwipeInvoiceRow: Row<SwipeInvoiceRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<SwipeInvoiceRowView>(nibName: "SwipeInvoiceCell")
    }
}


