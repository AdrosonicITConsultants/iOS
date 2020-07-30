//
//  DimensionsCardCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol DimensionCellProtocol {
    func showOption(tag: Int)
}

class DimensionsCardCell: UICollectionViewCell {

    var dimensionDelegate: DimensionCellProtocol?
    var option1: [String]?
    var option2: [String]?
    var option3: [String]?
    @IBOutlet weak var cardImg: UIImageView!
    @IBOutlet weak var cardTitle: UILabel!
    @IBOutlet weak var optionalLbl: UILabel!
    @IBOutlet weak var optionOneLbl: UILabel!
    @IBOutlet weak var optionTwoLbl: UILabel!
    @IBOutlet weak var optionThreeLbl: UILabel!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    @IBAction func optionSelected(_ sender: Any) {
        let btn = sender as! UIButton
        dimensionDelegate?.showOption(tag: btn.tag)
    }
}
