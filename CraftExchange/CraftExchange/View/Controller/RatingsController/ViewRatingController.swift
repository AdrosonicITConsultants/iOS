//
//  ViewRatingController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 30/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ViewRow
import WebKit
import Cosmos

class ViewRatingViewModel {
    var viewWillAppear: (() -> ())?
    var viewDidAppear: (() -> ())?
   
}
class ViewRatingController: FormViewController {
    
    lazy var viewModel = ViewRatingViewModel()
    let realm = try? Realm()
    var isClosed = false
    override func viewDidLoad() {
        super.viewDidLoad()
        let realm = try? Realm()
        
        form +++
            Section()
            <<< ViewRatingRow() {
                $0.cell.height = { 200.0 }
                $0.tag = "ViewRating"
            }
            <<< LabelRow() {
                $0.title = "Response"
            }
            <<< LabelRow() {
                $0.title = "Rate the artisan"
            }
            <<< GiveRatingRow() {
                $0.cell.height = { 150.0 }
                $0.tag = "GiveRating-1"
            }
            <<< RatingStarsRow() {
                $0.cell.height = { 100.0 }
                $0.cell.TitleLabel.text = "Artisan friendliness"
                $0.tag = "StarsRating-1"
            }
            <<< RatingStarsRow() {
                $0.cell.height = { 100.0 }
                $0.tag = "StarsRating-2"
                $0.cell.TitleLabel.text = "Artisan query resolution"
            }
            <<< RatingStarsRow() {
                $0.cell.height = { 100.0 }
                $0.tag = "StarsRating-3"
                $0.cell.TitleLabel.text = "Artisan's quality of product"
            }
            <<< RatingStarsRow() {
                $0.cell.height = { 100.0 }
                $0.tag = "StarsRating-4"
                $0.cell.TitleLabel.text = "Artisan's ability to accomodate changes"
                
            }
            <<< RatingStarsRow() {
                $0.cell.height = { 100.0 }
                $0.tag = "StarsRating-5"
                $0.cell.TitleLabel.text = "Overall experience"
                
            }
            
            <<< RatingTextFieldRow() {
                $0.cell.height = { 500.0 }
                $0.tag = "RatingTextView"
                $0.cell.Description.layer.borderWidth = 1
                $0.cell.Description.layer.borderColor = UIColor.black.cgColor
                
            }
            <<< RoundedButtonViewRow("swipe") {
                $0.tag = "Swipe"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = .black
                $0.cell.buttonView.backgroundColor = .black
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Submit".localized, for: .normal)
                $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = 900
                $0.cell.height = { 80.0 }
        }
    }
}

