//
//  QCStage1.swift
//  CraftExchange
//
//  Created by Kiran Songire on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

//protocol uploadSuccessProtocol {
//    func ViewTransactionBtnSelected(tag: Int)
//}

class QCStage1: Cell<String>, CellType {

    
    @IBOutlet weak var NextLabel: UILabel!
    @IBOutlet weak var InProgressLabel: UILabel!
    @IBOutlet weak var CompleteMarkBtn: UIButton!
    @IBOutlet weak var ArrowImg: UIImageView!
    @IBOutlet weak var BottomLabel: UILabel!
//    var delegate: uploadSuccessProtocol!
    
    public override func setup() {
        super.setup()
//        ViewTransactionBtn.addTarget(self, action: #selector(ViewTransactionButtonSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @IBAction func ViewTransactionButtonSelected(_ sender: Any) {
//           delegate?.ViewTransactionBtnSelected(tag: tag)
          
       }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class QCStage1Row: Row<QCStage1>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<QCStage1>(nibName: "QCStage1")
    }
}
