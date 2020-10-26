//
//  CRArtisanRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class CRArtisanRowView: Cell<String>, CellType {

    @IBOutlet weak var tickBtn: UIButton!
    @IBOutlet weak var labelField: UILabel!
    @IBOutlet weak var valuefield: UILabel!
    
    public override func setup() {
        super.setup()
        tickBtn.setImage(UIImage.init(systemName: "square"), for: .normal)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func checkmarkSelected(_ sender: Any) {
        if tickBtn.image(for: .normal) == UIImage.init(systemName: "square") {
            tickBtn.setImage(UIImage.init(systemName: "checkmark.square.fill"), for: .normal)
        }else {
            tickBtn.setImage(UIImage.init(systemName: "square"), for: .normal)
        }
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class CRArtisanRow: Row<CRArtisanRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CRArtisanRowView>(nibName: "CRArtisanRow")
    }
}

