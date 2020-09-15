//
//  StatusRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 07/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class StatusRowView: Cell<String>, CellType {


    @IBOutlet weak var previousStatusLbl: UILabel!
    @IBOutlet weak var currentStatusLbl: UILabel!
    @IBOutlet weak var actionLbl: UILabel!
    @IBOutlet weak var nextStatusLbl: UILabel!
    @IBOutlet weak var previousDotView: UIView!
    @IBOutlet weak var currentDotView: UIView!
    @IBOutlet weak var nextDotView: UIView!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class StatusRow: Row<StatusRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<StatusRowView>(nibName: "StatusRow")
    }
}

