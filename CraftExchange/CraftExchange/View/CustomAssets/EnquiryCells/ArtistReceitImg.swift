//
//  ArtistReceitImg.swift
//  CraftExchange
//
//  Created by Kiran Songire on 04/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka

class ArtistReceitImg: Cell<String>, CellType{

   
    @IBOutlet weak var AmountLabel: UILabel!
    @IBOutlet weak var ImageReceit: UIImageView!
    
    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}
final class ArtistReceitImgRow: Row<ArtistReceitImg>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ArtistReceitImg>(nibName: "ArtistReceitImg")
        
    }
}
