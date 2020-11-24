//
//  ToggleOptionRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 19/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol ToggleButtonProtocol {
    func toggleButtonSelected(tag:Int, forWashCare: Bool)
}

class ToggleOptionRowView: Cell<String>, CellType {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var toggleButton: UIButton!
    var washCare = false
    var toggleDelegate: ToggleButtonProtocol?
    
    public override func setup() {
        super.setup()
        toggleButton.addTarget(self, action: #selector(toggleSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func toggleSelected(_ sender:Any) {
        if titleLbl.textColor == .white {
            titleLbl.textColor = UIColor().menuSelectorBlue()
            toggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
        }else {
            titleLbl.textColor = .white
            toggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        }
        toggleDelegate?.toggleButtonSelected(tag: toggleButton.tag, forWashCare: washCare)
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ToggleOptionRow: Row<ToggleOptionRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ToggleOptionRowView>(nibName: "ToggleOptionRow")
    }
}
