//
//  AdminLabelCell.swift
//  CraftExchange
//
//  Created by Kiran Songire on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka


class AdminLabelCell: Cell<String>, CellType {


    
    @IBOutlet weak var AdminLabel: UILabel!
    
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class AdminLabelRow: Row<AdminLabelCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AdminLabelCell>(nibName: "AdminLabelCell")
    }
}

