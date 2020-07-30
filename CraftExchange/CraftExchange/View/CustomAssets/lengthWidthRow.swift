//
//  lengthWidthRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol LengthWidthCellProtocol {
  func lengthWidthSelected(tag: Int)
}

class lengthWidthRowView: Cell<String>, CellType {

    var lengthWidthDelegate: LengthWidthCellProtocol?
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var length: UIButton!
    @IBOutlet weak var width: UIButton!
    
    public override func setup() {
        super.setup()
        length.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
        width.addTarget(self, action: #selector(customButtonSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func customButtonSelected(_ sender: Any) {
      lengthWidthDelegate?.lengthWidthSelected(tag: tag)
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class lengthWidthRow: Row<lengthWidthRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<lengthWidthRowView>(nibName: "lengthWidthRow")
    }
}


