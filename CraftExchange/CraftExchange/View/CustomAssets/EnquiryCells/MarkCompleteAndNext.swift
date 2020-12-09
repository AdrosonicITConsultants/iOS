//
//  MarkCompleteAndNext.swift
//  CraftExchange
//
//  Created by Kiran Songire on 05/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka
protocol MarkCompleteAndNextProtocol {
    func MarkProgressSelected(tag: Int)
    func MarkCompleteNextSelected(tag: Int)
}

class MarkCompleteAndNext: Cell<String>, CellType {
    @IBOutlet weak var MarkProgress: UIButton!
    
    @IBOutlet weak var MarkCompleteNext: UIButton!
    @IBOutlet weak var BottomLabel: UILabel!
    var delegate: MarkCompleteAndNextProtocol?
    
    @IBAction func MarkCompleteNextSelected(_ sender: Any) {
        delegate?.MarkCompleteNextSelected(tag: tag)
        
    }
    @IBAction func MarkProgressSelected(_ sender: Any) {
        delegate?.MarkProgressSelected(tag: tag)
        
    }
    
    public override func setup() {
        super.setup()
        MarkProgress.addTarget(self, action: #selector(MarkProgressSelected(_:)), for: .touchUpInside)
        MarkCompleteNext.addTarget(self, action: #selector(MarkCompleteNextSelected(_:)), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class MarkCompleteAndNextRow: Row<MarkCompleteAndNext>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<MarkCompleteAndNext>(nibName: "MarkCompleteAndNext")
    }
}

