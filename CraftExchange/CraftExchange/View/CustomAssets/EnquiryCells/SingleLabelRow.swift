//
//  SingleLabelRow.swift
//  CraftExchange
//
//  Created by Kalyan on 28/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka


class SingleLabelRowView: Cell<String>, CellType {
    
    @IBOutlet weak var acceptLabel: UILabel!
    
    public override func setup() {
        super.setup()
    }
    
    
    public override func update() {
        super.update()
    }
}


final class SingleLabelRow: Row<SingleLabelRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<SingleLabelRowView>(nibName: "SingleLabelRow")
    }
    
    
}
