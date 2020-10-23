//
//  LabelUnderlinedView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 23/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class LabelUnderlinedView: Cell<String>, CellType {

    
    @IBOutlet weak var LabelHeader: UILabel!
    @IBOutlet weak var GrayLine: UIView!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class LabelUnderlinedRow: Row<LabelUnderlinedView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<LabelUnderlinedView>(nibName: "LabelUnderlinedView")
    }
}


