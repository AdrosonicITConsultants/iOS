//
//  MOQAcceptView.swift
//  CraftExchange
//
//  Created by Kalyan on 28/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol MOQAcceptViewProtocol {
    func cancelButtonSelected()
    func acceptMOQButtonSelected()
}

class MOQAcceptView: UIView {
    
    
    @IBOutlet weak var brandClusterText: UILabel!
    
    @IBOutlet weak var moqText: UILabel!
    
    @IBOutlet weak var pricePerUnitText: UILabel!
    @IBOutlet weak var ETADaysText: UILabel!
    
    @IBOutlet weak var AcceptButton: RoundedButton!
    @IBOutlet weak var closeButton: UIButton!
    
    var delegate: MOQAcceptViewProtocol?
    @IBAction func acceptMOQButtonSelected(_ sender: Any) {
        delegate?.acceptMOQButtonSelected()
    }
    
    @IBAction func cancelButtonSelected(_ sender: Any) {
        delegate?.cancelButtonSelected()
        
    }
    /*    // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}
