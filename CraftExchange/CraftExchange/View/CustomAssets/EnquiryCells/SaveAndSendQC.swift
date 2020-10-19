//
//  SaveAndSendQC.swift
//  CraftExchange
//
//  Created by Kiran Songire on 19/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka

protocol SaveandSendBtnProtocol {
    func SaveandSend(tag: Int)
}

class SaveAndSendQC: Cell<String>, CellType {

   
    @IBOutlet weak var Btnsave: UIButton!
    @IBOutlet weak var Btnsend: UIButton!
    var delegate: SaveandSendBtnProtocol!

    public override func setup() {
        super.setup()
    }

    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class SaveAndSendQCRow: Row<SaveAndSendQC>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<SaveAndSendQC>(nibName: "SaveAndSendQC")
    }
}
