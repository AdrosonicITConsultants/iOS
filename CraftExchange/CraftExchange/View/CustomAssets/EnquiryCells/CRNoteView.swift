//
//  CRNoteView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka



class CRNoteView: Cell<String>, CellType {

    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Imagveiew: UIImageView!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class CRNoteViewRow: Row<CRNoteView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CRNoteView>(nibName: "CRNoteView")
    }
}
