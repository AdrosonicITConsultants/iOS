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

@objc protocol SaveAndSendBtnProtocol {
    @objc optional func saveQC(tag: Int)
    @objc optional func sendQC(tag: Int)
}

class SaveAndSendQC: Cell<String>, CellType {

   
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    var delegate: SaveAndSendBtnProtocol!

    public override func setup() {
        super.setup()
        btnSave.addTarget(self, action: #selector(saveButtonSelected(_:)), for: .touchUpInside)
        btnSend.addTarget(self, action: #selector(sendButtonSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func saveButtonSelected(_ sender: Any) {
      delegate?.saveQC?(tag: tag)
    }
    
    @IBAction func sendButtonSelected(_ sender: Any) {
      delegate?.sendQC?(tag: tag)
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
