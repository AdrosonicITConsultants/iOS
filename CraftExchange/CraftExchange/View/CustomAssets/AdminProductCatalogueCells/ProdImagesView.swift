//
//  ProdImagesView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 27/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class  ProdImagesView: Cell<String>, CellType {

    @IBOutlet weak var roundBtn: UIButton!
    @IBOutlet weak var editBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var prodScrollView: UIScrollView!
    @IBOutlet weak var prodImg3: UIImageView!
    @IBOutlet weak var prodImg2: UIImageView!
    @IBOutlet weak var prodImg1: UIImageView!
    @IBOutlet weak var prodNameLabel: UILabel!
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class  ProdImagesRow: Row< ProdImagesView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider< ProdImagesView>(nibName: "ProdImagesView")
    }
}


