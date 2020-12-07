//
//  ProdDetailsRelatedRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class ProdDetailsRelatedRowView: Cell<String>, CellType {
    
    @IBOutlet weak var rowImage: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var prodLbl: UILabel!
    @IBOutlet weak var relatedProdLbl: UILabel!
    @IBOutlet weak var prodValueLbl: UILabel!
    @IBOutlet weak var relatedProdValueLbl: UILabel!
    
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ProdDetailsRelatedRow: Row<ProdDetailsRelatedRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProdDetailsRelatedRowView>(nibName: "ProdDetailRelatedRow")
    }
}
