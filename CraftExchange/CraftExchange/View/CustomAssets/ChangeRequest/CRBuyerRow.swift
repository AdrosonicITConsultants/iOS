//
//  CRBuyerRow.swift
//  CraftExchange
//
//  Created by Kiran Songire on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class CRBuyerRowView: Cell<String>, CellType {

    @IBOutlet weak var Tickbtn: UIButton!
    @IBOutlet weak var LabelField: UILabel!
    @IBOutlet weak var CRTextfield: UITextField!
    
    public override func setup() {
        super.setup()
        Tickbtn.setImage(UIImage.init(systemName: "square"), for: .normal)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func checkmarkSelected(_ sender: Any) {
        if Tickbtn.image(for: .normal) == UIImage.init(systemName: "square") {
            Tickbtn.setImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
        }else {
            Tickbtn.setImage(UIImage.init(systemName: "square"), for: .normal)
        }
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class CRBuyerRow: Row<CRBuyerRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CRBuyerRowView>(nibName: "CRBuyerRow")
    }
}
