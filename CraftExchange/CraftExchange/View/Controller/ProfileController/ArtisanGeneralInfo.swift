//
//  ArtisanGeneralInfo.swift
//  CraftExchange
//
//  Created by Preety Singh on 11/07/20.
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
import ImageRow

class ArtisanGeneralInfo: FormViewController, ButtonActionProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none

        self.view.backgroundColor = .white
        form +++
            Section()
            /*<<< ImageRow() {
                $0.cell.imageView?.center = $0.cell.center
                $0.cell.imageView?.layer.cornerRadius = 30
                $0.cell.height = { 60.0 }
                $0.cell.imageView?.image = UIImage(named: "my-profile-icon")
                $0.sourceTypes = [.Camera, .PhotoLibrary, .SavedPhotosAlbum]
                $0.clearAction = .yes(style: UIAlertAction.Style.destructive)
            }.onChange({ (row) in
                if let image = row.value {
                    let imageData:NSData = image.pngData()! as NSData
                    print(imageData.length)
                }
            })*/
            <<< LabelRow() {
              $0.cell.height = { 150.0 }
              $0.cell.imageView?.frame = $0.cell.contentView.frame
              $0.cell.imageView?.image = UIImage(named: "my-profile-icon")
                $0.cell.imageView?.contentMode = .scaleAspectFit
            }.onCellSelection({ (cell, row) in
                let alert = UIAlertController.init(title: "Please select".localized, message: "", preferredStyle: .actionSheet)
                let action1 = UIAlertAction.init(title: "Gallery", style: .default) { (action) in
                  
                }
                alert.addAction(action1)
                let action2 = UIAlertAction.init(title: "Camera", style: .default) { (action) in
                  
                }
                alert.addAction(action2)
                let action3 = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                }
                alert.addAction(action3)
                self.present(alert, animated: true, completion: nil)
            })
            <<< LabelRow() {
                $0.cell.height = { 40.0 }
                $0.title = "Avg rating".localized
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
                cell.detailTextLabel?.textAlignment = .center
                cell.detailTextLabel?.text = "\(User.loggedIn()?.rating ?? 1) / 5"
                cell.detailTextLabel?.textColor = .systemBlue
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Name"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = "\(User.loggedIn()?.firstName ?? "") \(User.loggedIn()?.lastName ?? "")"
                $0.cell.valueTextField.textColor = .black
                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Email Id"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.email ?? ""
                $0.cell.valueTextField.textColor = .black
                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Email Id".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Mobile Number"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.mobile ?? ""
                $0.cell.valueTextField.textColor = .black
                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Mobile Number".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< LabelRow() {
                $0.cell.height = { 80.0 }
                $0.title = "Registered Address".localized
            }.cellUpdate({ (cell, row) in
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.addressString
                    }
                })
                cell.detailTextLabel?.text = addressString
                cell.detailTextLabel?.textColor = .black
                cell.detailTextLabel?.numberOfLines = 10
                cell.detailTextLabel?.font = .systemFont(ofSize: 12)
            })
            <<< RoundedButtonViewRow("EditArtisanDetails") {
                $0.tag = "EditArtisanDetails"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = .black
                $0.cell.buttonView.backgroundColor = .black
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Edit your details", for: .normal)
                $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = 101
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
            }
            <<< LabelRow() { row in
                row.cell.height = { 300.0 }
            }
    }
    
    func customButtonSelected(tag: Int) {
        //Edit selected
        let btnRow = self.form.rowBy(tag: "EditArtisanDetails") as? RoundedButtonViewRow
        if btnRow?.cell.buttonView.titleLabel?.text == "Edit your details" {
            btnRow?.cell.buttonView.setTitle("Save your details", for: .normal)
            btnRow?.cell.buttonView.borderColour = .red
            btnRow?.cell.buttonView.backgroundColor = .red
        }else {
            btnRow?.cell.buttonView.setTitle("Edit your details", for: .normal)
            btnRow?.cell.buttonView.borderColour = .black
            btnRow?.cell.buttonView.backgroundColor = .black
        }
        
    }
    
}
