//
//  AdminCardsCell.swift
//  CraftExchange
//
//  Created by Kiran Songire on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import Foundation
import UIKit
import Eureka
protocol ArrowBtnProtocol {
    func ArrowSelected(atIndex: Int)
}

class AdminCardsCell: Cell<String>, CellType {


    @IBOutlet weak var Scrollview: UIScrollView!
    @IBOutlet weak var B1: UIButton!
    @IBOutlet weak var b4: UIButton!
    @IBOutlet weak var b3: UIButton!
    @IBOutlet weak var b2: UIButton!
    
    @IBOutlet weak var Rb1: UIButton!
    @IBOutlet weak var Rb2: UIButton!
    @IBOutlet weak var Rb3: UIButton!
    @IBOutlet weak var Rb4: UIButton!
    @IBOutlet weak var Lb1: UIButton!
    @IBOutlet weak var Lb2: UIButton!
    @IBOutlet weak var Lb3: UIButton!
    @IBOutlet weak var Lb4: UIButton!
    var delegate: ArrowBtnProtocol?
    
    @IBAction func ArrowBtnSelected(_ sender: Any) {
        let btn = sender as! UIButton
        delegate?.ArrowSelected(atIndex: btn.tag)
    }
    
   
}

// The custom Row also has the cell: CustomCell and its correspond value
final class AdminCardsRow: Row<AdminCardsCell>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<AdminCardsCell>(nibName: "AdminCardsCell")
    }
}

