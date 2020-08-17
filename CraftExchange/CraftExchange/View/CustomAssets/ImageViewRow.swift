//
//  ImageViewRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class ImageViewRowView: Cell<String>, CellType {

    @IBOutlet weak var cellImage: UIImageView!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ImageViewRow: Row<ImageViewRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ImageViewRowView>(nibName: "ImageViewRow")
    }
}
