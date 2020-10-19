//
//  FillQCForm.swift
//  CraftExchange
//
//  Created by Kiran Songire on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol FormBtnProtocol {
    func FormBtnSelected(tag: Int)
}

class FillQCForm: Cell<String>, CellType {

    @IBOutlet weak var QCLabel: UILabel!
    
    @IBOutlet weak var FormBtn: UIButton!
    var delegate: FormBtnProtocol!
    
    public override func setup() {
        super.setup()
        FormBtn.addTarget(self, action: #selector(FormBtnSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func FormBtnSelected(_ sender: Any) {
           delegate?.FormBtnSelected(tag: tag)
          
       }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class FillQCFormRow: Row<FillQCForm>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<FillQCForm>(nibName: "FillQCForm")
    }
}
