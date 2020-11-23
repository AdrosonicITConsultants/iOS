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
    func ArrowSelected(tag: Int)
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
    
    let userEmail = User.loggedIn()?.email ?? ""
    var token = KeychainManager.standard.userAccessToken ?? ""
    
    public override func setup() {
        super.setup()
        B1.addTarget(self, action: #selector(ArrowBtnSelected(_:)), for: .touchUpInside)
        b2.addTarget(self, action: #selector(ArrowBtnSelected(_:)), for: .touchUpInside)
        b3.addTarget(self, action: #selector(ArrowBtnSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func ArrowBtnSelected(_ sender: UIButton) {
        
        let app = UIApplication.shared.delegate as? AppDelegate
        app?.dashboardType = sender.tag
        
        delegate?.ArrowSelected(tag: tag)
         
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

