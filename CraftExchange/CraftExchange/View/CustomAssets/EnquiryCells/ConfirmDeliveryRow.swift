//
//  ConfirmDeliveryRow.swift
//  CraftExchange
//
//  Created by Kalyan on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol ConfirmDeliveryProtocol {
    func ConfirmDeliveryInitationBtnSelected(tag: Int)
}

class ConfirmDeliveryRowView: Cell<String>, CellType {
    
    @IBOutlet weak var ConfirmDeliveryInitationButton: UIButton!
    
    var delegate: ConfirmDeliveryProtocol?
    
    public override func setup() {
        super.setup()
        ConfirmDeliveryInitationButton.addTarget(self, action: #selector(ConfirmDeliveryInitationBtnSelected), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func ConfirmDeliveryInitationBtnSelected(_ sender: Any) {
        delegate?.ConfirmDeliveryInitationBtnSelected(tag: tag)
    }
    
}

final class ConfirmDeliveryRow: Row<ConfirmDeliveryRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ConfirmDeliveryRowView>(nibName: "ConfirmDeliveryRow")
    }
}
