//
//  StartStageView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka

protocol StartstageProtocol {
    func StartstageBtnSelected(tag: Int)
}
class StartStageView: Cell<String>, CellType {
    
    
    
    @IBOutlet weak var Startstage: UIButton!
    
    @IBOutlet weak var BottomLabel: UILabel!
    var delegate: StartstageProtocol?
    @IBAction func StartstageBtnSelected(_ sender: Any) {
        delegate?.StartstageBtnSelected(tag: tag)
        
    }
    public override func setup() {
        super.setup()
        Startstage.addTarget(self, action: #selector(StartstageBtnSelected(_:)), for: .touchUpInside)
        
    }
    
    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class StartStageViewRow: Row<StartStageView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<StartStageView>(nibName: "StartStageView")
    }
}

