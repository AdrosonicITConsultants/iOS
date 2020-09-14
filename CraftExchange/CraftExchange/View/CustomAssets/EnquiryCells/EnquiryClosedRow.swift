//
//  EnquiryClosedRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 14/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class EnquiryClosedRowView: Cell<String>, CellType {

    @IBOutlet weak var dotView: UIView!
    @IBOutlet weak var enquiryLabel: UILabel!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class EnquiryClosedRow: Row<EnquiryClosedRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<EnquiryClosedRowView>(nibName: "EnquiryClosedRow")
    }
}

