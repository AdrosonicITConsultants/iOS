//
//  ArtisanBrandDetails.swift
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

class ArtisanBrandDetailsViewModel {
    var companyName = Observable<String?>(nil)
    var compDesc = Observable<String?>(nil)
    var productCatIds = Observable<[Int]?>(nil)
    var imageData = Observable<(Data,String)?>(nil)
}

class ArtisanBrandDetails: FormViewController, ButtonActionProtocol {
    
    var isEditable = false
    var viewModel = ArtisanBrandDetailsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        NotificationCenter.default.addObserver(self, selector: #selector(updateLogoPic), name: NSNotification.Name("loadLogoImage"), object: nil)
        self.view.backgroundColor = .white
        let parentVC = self.parent as? BuyerProfileController
        
        form +++
            Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                if let _ = User.loggedIn()?.logoUrl, let name = User.loggedIn()?.buyerCompanyDetails.first?.logo {
                    do {
                        let downloadedImage = try Disk.retrieve("\(User.loggedIn()?.entityID ?? 84)/\(name)", from: .caches, as: UIImage.self)
                        $0.cell.actionButton.setImage(downloadedImage, for: .normal)
                    }catch {
                        print(error)
                    }
                    if parentVC?.reachabilityManager?.connection != .unavailable {
                        refreshBrandLogo()
                    }
                } else if parentVC?.reachabilityManager?.connection != .unavailable {
                    refreshBrandLogo()
                } else {
                    $0.cell.actionButton.setImage(UIImage.init(named: "user"), for: .normal)
                }
            }.cellUpdate({ (cell, row) in
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.actionButton.isUserInteractionEnabled = true
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.actionButton.isUserInteractionEnabled = false
                }
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Name"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.buyerCompanyDetails.first?.companyName ?? ""
                $0.cell.valueTextField.textColor = .black
                $0.cell.valueTextField.leftPadding = 0
                self.viewModel.companyName.value = $0.cell.valueTextField.text
                self.viewModel.companyName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Name".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.companyName.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Cluster"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.cluster?.clusterDescription ?? ""
                $0.cell.valueTextField.textColor = .black
                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Cluster".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Product Category"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.textColor = .black
                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Product Category".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                var finalString = ""
                User.loggedIn()?.userProductCategories .forEach({ (cat) in
                    finalString.append("\(cat.categoryString) ")
                })
                print("final string \n\n \(finalString) \(User.loggedIn()?.userProductCategories.count ?? 0)")
                cell.valueTextField.text = finalString
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Description"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .white
                $0.cell.valueTextField.text = User.loggedIn()?.buyerCompanyDetails.first?.compDesc ?? ""
                $0.cell.valueTextField.textColor = .black
                self.viewModel.compDesc.value = $0.cell.valueTextField.text
                self.viewModel.compDesc.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Description".localized
                cell.titleLabel.textColor = .black
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.compDesc.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
            <<< RoundedButtonViewRow("EditArtisanBrandDetails") {
                $0.tag = "EditArtisanBrandDetails"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = .black
                $0.cell.buttonView.backgroundColor = .black
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Edit brand details".localized, for: .normal)
                $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = 101
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
            }
            <<< LabelRow() { row in
                row.cell.height = { 300.0 }
            }
    }
    
    func refreshBrandLogo() {
        if let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID {
            let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/User/\(userID)/CompanyDetails/Logo/\(name)")
            URLSession.shared.dataTask(with: url!) { data, response, error in
                // do your stuff here...
                DispatchQueue.main.async {
                    // do something on the main queue
                    if error == nil {
                        if let finalData = data {
                            User.loggedIn()?.saveOrUpdateBrandLogo(data: finalData)
                            NotificationCenter.default.post(name: Notification.Name("loadLogoImage"), object: nil)
                        }
                    }
                }
            }.resume()
        }
    }
    
    func customButtonSelected(tag: Int) {
        //Edit selected
        let btnRow = self.form.rowBy(tag: "EditArtisanBrandDetails") as? RoundedButtonViewRow
        if btnRow?.cell.buttonView.titleLabel?.text == "Edit brand details".localized {
            isEditable = true
            btnRow?.cell.buttonView.setTitle("Save brand details".localized, for: .normal)
            btnRow?.cell.buttonView.borderColour = .red
            btnRow?.cell.buttonView.backgroundColor = .red
        }else {
            isEditable = false
            btnRow?.cell.buttonView.setTitle("Edit brand details".localized, for: .normal)
            btnRow?.cell.buttonView.borderColour = .black
            btnRow?.cell.buttonView.backgroundColor = .black
            if let parentVC = self.parent as? BuyerProfileController {
                let newCompDetails = buyerCompDetails.init(id: User.loggedIn()?.buyerCompanyDetails.first?.entityID ?? 0, companyName: self.viewModel.companyName.value, cin: nil, contact: nil, gstNo: nil, logo: nil, compDesc: self.viewModel.compDesc.value)
                if self.viewModel.imageData.value != nil {
                    parentVC.viewModel.updateArtisanBrandDetails?(newCompDetails.toJSON(), self.viewModel.imageData.value?.0, self.viewModel.imageData.value?.1)
                }else {
                    parentVC.viewModel.updateArtisanBrandDetails?(newCompDetails.toJSON(), nil, nil)
                }
                
            }
        }
        for row in self.form.allRows {
            if row.tag == "Name" || row.tag == "Description" || row.tag == "ProfileView" {
                row.updateCell()
            }
        }
    }
    
    @objc func updateLogoPic() {
        if let _ = User.loggedIn()?.logoUrl, let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID {
            let row = self.form.rowBy(tag: "ProfileView") as? ProfileImageRow
            do {
                let downloadedImage = try Disk.retrieve("\(userID)/\(name)", from: .caches, as: UIImage.self)
                row?.cell.actionButton.setImage(downloadedImage, for: .normal)
            }catch {
                print(error)
            }
        }
    }
    
}

extension ArtisanBrandDetails: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        let row = self.form.rowBy(tag: "ProfileView") as? ProfileImageRow
        row?.cell.actionButton.setImage(selectedImage, for: .normal)
        var imgdata: Data?
        if let compressedImg = selectedImage.resizedTo1MB() {
            if let data = compressedImg.pngData() {
                imgdata = data
            } else if let data = compressedImg.jpegData(compressionQuality: 1) {
                imgdata = data
            }
        }else {
            if let data = selectedImage.pngData() {
                imgdata = data
            } else if let data = selectedImage.jpegData(compressionQuality: 0.5) {
                imgdata = data
            }
        }
        self.viewModel.imageData.value = (imgdata, "logo.jpg") as? (Data, String)
        picker.dismiss(animated: true, completion: nil)
    }
}


