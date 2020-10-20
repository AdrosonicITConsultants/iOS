//
//  checkboxField.swift
//  CraftExchange
//
//  Created by Kiran Songire on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka



class checkboxField: Cell<String>, CellType {

    @IBOutlet weak var Tickbtn: UIButton!
    
    @IBOutlet weak var LabelField: UILabel!
    
    @IBOutlet weak var CRTextfield: UITextField!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
    
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class checkboxFieldRow: Row<checkboxField>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<checkboxField>(nibName: "checkboxField")
    }
}
