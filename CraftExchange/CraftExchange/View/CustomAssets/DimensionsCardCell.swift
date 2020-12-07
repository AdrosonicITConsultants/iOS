//
//  DimensionsCardCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Realm

protocol DimensionCellProtocol {
    func showOption(tag: Int, withValue: String)
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
    @IBOutlet weak var yarnCountTextField: UITextField!
    
    var allYarns: Results<Yarn>?
    
    @IBAction func optionSelected(_ sender: Any) {
        let btn = sender as! UIButton
        var options: [String] = []
        if btn.tag == 101 || btn.tag == 201 || btn.tag == 301 {
            options = option1 ?? []
        }else if btn.tag == 102 || btn.tag == 202 || btn.tag == 302 {
            options = option2 ?? []
        }else if btn.tag == 103 || btn.tag == 203 || btn.tag == 303 {
            options = option3 ?? []
        }
        let alert = UIAlertController.init(title: "Please select".localized, message: "", preferredStyle: .actionSheet)
        for option in options {
            let action = UIAlertAction.init(title: option, style: .default) { (action) in
                btn.setTitle(option, for: .normal)
                self.dimensionDelegate?.showOption(tag: btn.tag, withValue: option)
                if btn.tag == 101 || btn.tag == 201 || btn.tag == 301 {
                    self.resetYarnCount()
                    if self.option2 != nil && self.option2?.count == 0 {
                        self.yarnCountTextField.isHidden = false
                        self.buttonTwo.isHidden = true
                        self.buttonTwo.isUserInteractionEnabled = false
                        self.yarnCountTextField.text = ""
                    }else {
                        self.yarnCountTextField.isHidden = true
                        self.buttonTwo.isHidden = false
                        self.buttonTwo.setTitle("", for: .normal)
                        self.buttonTwo.isUserInteractionEnabled = true
                        self.yarnCountTextField.text = ""
                    }
                }
            }
            alert.addAction(action)
        }
        let action = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(action)
        (dimensionDelegate as? UIViewController)?.present(alert, animated: true, completion: nil)
    }
    
    func resetYarnCount() {
        let realm = try! Realm()
        allYarns = realm.objects(Yarn.self).sorted(byKeyPath: "entityID")
        
        let selectedObj = self.allYarns?.filter({ (obj) -> Bool in
            obj.yarnDesc == self.buttonOne.titleLabel?.text
        }).first
        self.option2 = selectedObj?.yarnType.first?.yarnCounts.compactMap({$0.count})
    }
}
