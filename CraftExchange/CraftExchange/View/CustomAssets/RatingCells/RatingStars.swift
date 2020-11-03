//
//  RatingStars.swift
//  CraftExchange
//
//  Created by Kiran Songire on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka
import Cosmos


class  RatingStars: Cell<String>, CellType {
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var StarsView: CosmosView!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class  RatingStarsRow: Row<RatingStars>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<RatingStars>(nibName: "RatingStars")
    }
}




