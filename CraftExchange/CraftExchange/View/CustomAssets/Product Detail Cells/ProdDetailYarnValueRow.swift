//
//  ProdDetailYarnValueRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class ProdDetailYarnValueRowView: Cell<String>, CellType {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var valueLbl1: UILabel!
    @IBOutlet weak var valueLbl2: UILabel!
    @IBOutlet weak var valueLbl3: UILabel!
    @IBOutlet weak var rowImage: UIImageView!
    @IBOutlet weak var rowImageWidthConstraint: NSLayoutConstraint!
    
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ProdDetailYarnValueRow: Row<ProdDetailYarnValueRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProdDetailYarnValueRowView>(nibName: "ProdDetailYarnValueRow")
    }
}
