//
//  AdminBrandDetails.swift
//  CraftExchange
//
//  Created by Kiran Songire on 22/10/20.
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

class AdminBrandDetailsViewModel {
    var companyName = Observable<String?>(nil)
    var compDesc = Observable<String?>(nil)
    var productCatIds = Observable<[Int]?>(nil)
    var imageData = Observable<(Data,String)?>(nil)
}

class AdminBrandDetails: FormViewController {
    
    var isEditable = false
    var viewModel = AdminBrandDetailsViewModel()
    var allCategories: Results<ProductCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.backgroundColor = .black
        NotificationCenter.default.addObserver(self, selector: #selector(updateLogoPic), name: NSNotification.Name("loadLogoImage"), object: nil)
        self.view.backgroundColor = .white
        let parentVC = self.parent as? BuyerProfileController
        let realm = try! Realm()
        allCategories = realm.objects(ProductCategory.self).sorted(byKeyPath: "entityID")
        let catTypeSection = Section(){ section in
            section.tag = "CategorySection"
            section.header?.title = "Product Category".localized
        }
        
        var strArr:[String] = []
        self.viewModel.productCatIds.value = []
        User.loggedIn()?.userProductCategories .forEach({ (cat) in
            strArr.append("\(ProductCategory.getProductCat(catId: cat.productCategoryId)?.prodCatDescription ?? "")")
            self.viewModel.productCatIds.value?.append(cat.productCategoryId)
        })
        
        if let setWeave = allCategories?.compactMap({$0}) {
            setWeave.forEach({ (cat) in
                catTypeSection <<< ToggleOptionRow() {
                    $0.cell.height = { 45.0 }
                    $0.cell.titleLbl.text = cat.prodCatDescription ?? ""
                    if strArr.contains(cat.prodCatDescription ?? "") {
                        $0.cell.titleLbl.textColor = UIColor().menuSelectorBlue()
                        $0.cell.toggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                    }else {
                        $0.cell.titleLbl.textColor = .lightGray
                        $0.cell.toggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                    }
                    $0.cell.washCare = false
                    $0.cell.toggleButton.tag = cat.entityID
                    }.cellUpdate({ (cell, row) in
                        if self.isEditable {
                            cell.isUserInteractionEnabled = true
                            cell.toggleButton.isUserInteractionEnabled = true
                        }else {
                            cell.isUserInteractionEnabled = false
                            cell.toggleButton.isUserInteractionEnabled = false
                        }
                    }).onCellSelection({ (cell, row) in
                    cell.toggleButton.sendActions(for: .touchUpInside)
                    cell.contentView.backgroundColor = .white
                })
            })
        }
        
        form +++
            Section()
            <<< BrandDetailRow() {
                $0.tag = "BrandLogo"
                $0.cell.height = { 100.0 }
                $0.cell.backgroundColor = .black
                $0.cell.BrandName.text = "Chidiya"
            }
            <<< RoundedTextFieldRow() {
                $0.tag = "Product Category"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = "Sareee"

//                $0.cell.valueTextField.text = User.loggedIn()?.buyerCompanyDetails.first?.companyName ?? ""
                $0.cell.valueTextField.textColor = .white
                $0.cell.valueTextField.leftPadding = 0
                self.viewModel.companyName.value = $0.cell.valueTextField.text
                self.viewModel.companyName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Product Category".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
                self.viewModel.companyName.value = cell.valueTextField.text
                if self.isEditable {
                    cell.isUserInteractionEnabled = true
                    cell.valueTextField.isUserInteractionEnabled = true
//                    cell.valueTextField.layer.borderColor = UIColor.black.cgColor
                    cell.valueTextField.leftPadding = 10
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.valueTextField.isUserInteractionEnabled = false
//                    cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                    cell.valueTextField.leftPadding = 0
                }
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Cluster"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.valueTextField.isUserInteractionEnabled = false
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = "Nagaland"
//                $0.cell.valueTextField.text = User.loggedIn()?.cluster?.clusterDescription ?? ""
                $0.cell.valueTextField.textColor = .white
//                $0.cell.valueTextField.layer.borderColor = UIColor.white.cgColor
                $0.cell.valueTextField.leftPadding = 0
                $0.cell.isUserInteractionEnabled = false
            }.cellUpdate({ (cell, row) in
                cell.titleLabel.text = "Cluster".localized
                cell.titleLabel.textColor = .white
                cell.titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
                cell.valueTextField.font = .systemFont(ofSize: 16, weight: .regular)
            })
            
            +++ catTypeSection
            +++ Section()
            
    }
    
    func refreshBrandLogo() {
        if let name = User.loggedIn()?.buyerCompanyDetails.first?.logo, let userID = User.loggedIn()?.entityID {
            let url = URL(string: "\(KeychainManager.standard.imageBaseURL)/User/\(userID)/CompanyDetails/Logo/\(name)")
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

