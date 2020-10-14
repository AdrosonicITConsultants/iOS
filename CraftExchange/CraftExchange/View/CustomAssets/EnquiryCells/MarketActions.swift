//
//  MarketActions.swift
//  CraftExchange
//
//  Created by Kiran Songire on 12/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class MarketActions:Cell<String>, CellType {

    @IBOutlet weak var ActionBtn: UIButton!
    
    @IBOutlet weak var ArrowBtn: UIButton!
    @IBOutlet weak var ActionImg: UIImageView!
    @IBOutlet weak var ActionLabel: UILabel!
    public override func setup() {
        super.setup()
       
    }

    public override func update() {
        super.update()
    }
    
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class MarketActionsRow: Row<MarketActions>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<MarketActions>(nibName: "MarketActions")
    }
}

