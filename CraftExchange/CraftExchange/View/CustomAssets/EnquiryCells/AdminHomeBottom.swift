//
//  AdminHomeBottom.swift
//  CraftExchange
//
//  Created by Kiran Songire on 12/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class AdminHomeBottom: Cell<String>, CellType {

    
    @IBOutlet weak var OngoingBtn: RoundedButton!
    
    @IBOutlet weak var ClosedBtn: RoundedButton!
    
    @IBOutlet weak var Logout: UIButton!
    public override func setup() {
        super.setup()
       
    }

    public override func update() {
        super.update()
    }
    
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class AdminHomeBottomRow: Row<AdminHomeBottom>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AdminHomeBottom>(nibName: "AdminHomeBottom")
    }
}
