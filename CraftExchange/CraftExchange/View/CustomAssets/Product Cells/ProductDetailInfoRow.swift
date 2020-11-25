//
//  ProductDetailInfoRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 18/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class ProductDetailInfoRowView: Cell<String>, CellType {

    @IBOutlet weak var productCatLbl: UILabel!
    @IBOutlet weak var productTypeLbl: UILabel!
    @IBOutlet weak var productAvailabilityLbl: UILabel!
    @IBOutlet weak var madeToOrderLbl: UILabel!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ProductDetailInfoRow: Row<ProductDetailInfoRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ProductDetailInfoRowView>(nibName: "ProductDetailInfoRow")
    }
}