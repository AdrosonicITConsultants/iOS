//
//  CompleteOrderIconRow.swift
//  CraftExchange
//
//  Created by Kalyan on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Eureka

class CompleteOrderIconRowView: Cell<String>, CellType {

    public override func setup() {
        super.setup()

    }

    public override func update() {
        super.update()
    }
    
}
final class CompleteOrderIconRow: Row<CompleteOrderIconRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CompleteOrderIconRowView>(nibName: "CompleteOrderIconRow")
    }
}
