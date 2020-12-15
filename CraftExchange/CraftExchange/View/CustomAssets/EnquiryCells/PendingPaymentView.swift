//
//  PendingPaymentView.swift
//  CraftExchange
//
//  Created by Kalyan on 14/12/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol PendingPaymentProtocol {
    func pendingPaymentButtonSelected(tag: Int)
    
}

class PendingPaymentView: Cell<String>, CellType {

    @IBOutlet weak var advanceAmountPaid: UILabel!
    
    @IBOutlet weak var pendingPaymentValue: RoundedButton!
    @IBOutlet weak var pendingPaymentButton: RoundedButton!
    var delegate: PendingPaymentProtocol?
    
    public override func setup() {
    super.setup()
        pendingPaymentButton.addTarget(self, action: #selector(pendingPaymentButtonSelected(_:)), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
    @IBAction func pendingPaymentButtonSelected(_ sender: Any) {
        delegate?.pendingPaymentButtonSelected(tag: tag)

    }
    
    
}

final class PendingPaymentRow: Row<PendingPaymentView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<PendingPaymentView>(nibName: "PendingPaymentView")
    }
}
