//
//  UploadSuccessfulView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 30/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol uploadSuccessProtocol {
    func ViewTransactionBtnSelected(tag: Int)
}

class UploadSuccessfulView: Cell<String>, CellType {

    @IBOutlet weak var Tick: UIImageView!
    @IBOutlet weak var ThankyouLabel: UILabel!
    @IBOutlet weak var PleaseNoteLabel: UILabel!
    
    @IBOutlet weak var ViewTransactionBtn: UIButton!
    @IBOutlet weak var EnquiryLabel: UILabel!
    
    var delegate: uploadSuccessProtocol!
    
    public override func setup() {
        super.setup()
        ViewTransactionBtn.addTarget(self, action: #selector(ViewTransactionButtonSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func ViewTransactionButtonSelected(_ sender: Any) {
           delegate?.ViewTransactionBtnSelected(tag: tag)
          
       }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class UploadSuccessfulRow: Row<UploadSuccessfulView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<UploadSuccessfulView>(nibName: "UploadSuccessfulView")
    }
}
