//
//  ViewRatingCell.swift
//  CraftExchange
//
//  Created by Kiran Songire on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka



class  ViewRatingCell: Cell<String>, CellType {
    @IBOutlet weak var RatingLabel: UILabel!
    @IBOutlet weak var StarImg: UIImageView!
    @IBOutlet weak var BackgroundImg: UIImageView!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class  ViewRatingRow: Row< ViewRatingCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider< ViewRatingCell>(nibName: "ViewRatingCell")
    }
}




