//
//  uploadRecieptView.swift
//  CraftExchange
//
//  Created by Kiran Songire on 29/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

protocol uploadtransactionProtocol {
    func UploadBtnSelected(tag: Int)
    func UploadImageBtnSelected(tag: Int)
}

class uploadRecieptView: Cell<String>, CellType {
    
    @IBOutlet weak var LabelInst: UILabel!
    @IBOutlet weak var ImgFormat: UILabel!
    
    var delegate: uploadtransactionProtocol!
    @IBOutlet weak var uploadImgBtn: UIButton!
    
    @IBOutlet weak var BottomLabel: UILabel!
    @IBOutlet weak var UploadBtn: UIButton!
    
    public override func setup() {
        super.setup()
        uploadImgBtn.addTarget(self, action: #selector(uploadImgButtonSelected(_:)), for: .touchUpInside)
        UploadBtn.addTarget(self, action: #selector(uploadButtonSelected), for: .touchUpInside)
    }
    
    public override func update() {
        super.update()
    }
    
    @IBAction func uploadImgButtonSelected(_ sender: Any) {
        delegate?.UploadImageBtnSelected(tag: tag)
       
    }
    @IBAction func uploadButtonSelected(_ sender: Any) {
        delegate?.UploadBtnSelected(tag: tag)
       
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class uploadRecieptRow: Row<uploadRecieptView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<uploadRecieptView>(nibName: "uploadRecieptView")
    }
}
