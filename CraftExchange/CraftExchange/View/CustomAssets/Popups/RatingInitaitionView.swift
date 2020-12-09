//
//  RatingInitaitionView.swift
//  CraftExchange
//
//  Created by Kalyan on 02/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol RatingInitaitionViewProtocol {
    func RevewAndRatingBtnSelected()
    func skipBtnSelected()
}

class RatingInitaitionView: UIView {
    
    @IBOutlet weak var RevewAndRatingButton: UIButton!
    
    @IBOutlet weak var skipbutton: UIButton!
    
    var delegate: RatingInitaitionViewProtocol?
    
    @IBAction func RevewAndRatingBtnSelected(_ sender: Any) {
        delegate?.RevewAndRatingBtnSelected()
    }
    @IBAction func skipBtnSelected(_ sender: Any) {
        delegate?.skipBtnSelected()
    }
    
}
