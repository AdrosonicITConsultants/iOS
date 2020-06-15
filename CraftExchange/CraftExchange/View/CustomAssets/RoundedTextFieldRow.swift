//
//  RoundedTextFieldRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class RoundedTextFieldView: Cell<String>, CellType {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueTextField: RoundedTextField!
  @IBOutlet var compulsoryIcon: UIImageView!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
        //backgroundColor = (row.value ?? false) ? .white : .black
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class RoundedTextFieldRow: Row<RoundedTextFieldView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RoundedTextFieldView>(nibName: "RoundedTextFieldRow")
    }
}
