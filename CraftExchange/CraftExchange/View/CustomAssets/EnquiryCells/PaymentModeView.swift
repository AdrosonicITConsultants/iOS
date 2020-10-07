//
//  PaymentModeView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 30/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class PaymentModeView: Cell<String>, CellType {

    @IBOutlet weak var paymentIcon: UIImageView!
    
    @IBOutlet weak var PaymentModeLbl: UILabel!
    @IBOutlet weak var PaymentValueLbl: UILabel!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class PaymentModeRow: Row<PaymentModeView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<PaymentModeView>(nibName: "PaymentModeView")
    }
}


