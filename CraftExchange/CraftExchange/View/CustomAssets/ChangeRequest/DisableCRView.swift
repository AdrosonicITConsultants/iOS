//
//  DisableCRView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka



class DisableCRView: Cell<String>, CellType {

    @IBOutlet weak var BtnCancel: RoundedButton!
    @IBOutlet weak var BtnOk: RoundedButton!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class DisableCRRow: Row<DisableCRView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<DisableCRView>(nibName: "DisableCRView")
    }
}

