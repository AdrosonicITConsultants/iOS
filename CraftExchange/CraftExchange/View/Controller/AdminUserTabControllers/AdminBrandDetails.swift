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
    var userObject: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.backgroundColor = .black
        NotificationCenter.default.addObserver(self, selector: #selector(updateLogoPic), name: NSNotification.Name("loadLogoImage"), object: nil)
        self.view.backgroundColor = .white
        
        form +++
            Section()
            <<< BrandDetailRow() {
                $0.tag = "BrandLogo"
                $0.cell.height = { 100.0 }
                $0.cell.backgroundColor = .black
                $0.cell.BrandName.text = userObject?.buyerCompanyDetails.first?.companyName
            }.cellUpdate({ (cell, row) in
                cell.BrandLogo.image = UIImage.init(named: "user")
                if let _ = self.userObject?.logoUrl, let name = self.userObject?.buyerCompanyDetails.first?.logo, let userID = self.userObject?.entityID {
                    do {
                        let downloadedImage = try Disk.retrieve("\(userID)/\(name)", from: .caches, as: UIImage.self)
                        cell.BrandLogo.image = downloadedImage
                    }catch {
                        print(error)
                    }
                    self.refreshProfileImage()
                } else {
                    self.refreshProfileImage()
                }
            })
            <<< RoundedTextFieldRow() {
                $0.tag = "Product Category"
                $0.cell.height = { 80.0 }
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.backgroundColor = .black
                $0.cell.valueTextField.text = userObject?.productCategories ?? ""
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
                $0.cell.valueTextField.text = userObject?.cluster?.clusterDescription ?? userObject?.clusterString ?? ""
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
    }
    
    func refreshBrandLogo() {
        if let name = userObject?.buyerCompanyDetails.first?.logo, let userID = userObject?.entityID {
            let url = URL(string: "\(KeychainManager.standard.imageBaseURL)/User/\(userID)/CompanyDetails/Logo/\(name)")
            URLSession.shared.dataTask(with: url!) { data, response, error in
                // do your stuff here...
                DispatchQueue.main.async {
                    // do something on the main queue
                    if error == nil {
                        if let finalData = data {
                            self.userObject?.saveOrUpdateBrandLogo(data: finalData)
                            NotificationCenter.default.post(name: Notification.Name("loadLogoImage"), object: nil)
                        }
                    }
                }
            }.resume()
        }
    }
    
   func refreshProfileImage() {
       if let name = userObject?.buyerCompanyDetails.first?.logo, let userID = userObject?.entityID  {
           let url = URL(string: "\(KeychainManager.standard.imageBaseURL)/User/\(userID)/CompanyDetails/Logo/\(name)")
           URLSession.shared.dataTask(with: url!) { data, response, error in
               // do your stuff here...
               DispatchQueue.main.async {
                   // do something on the main queue
                   if error == nil {
                       if let finalData = data {
                        self.userObject?.saveOrUpdateBrandLogo(data: finalData)
                           NotificationCenter.default.post(name: Notification.Name("loadLogoImage"), object: nil)
                       }
                   }
               }
           }.resume()
       }
   }
    
    @objc func updateLogoPic() {
        if let _ = userObject?.logoUrl, let name = userObject?.buyerCompanyDetails.first?.logo, let userID = userObject?.entityID {
            let row = self.form.rowBy(tag: "BrandLogo") as? BrandDetailRow
            do {
                let downloadedImage = try Disk.retrieve("\(userID)/\(name)", from: .caches, as: UIImage.self)
                row?.cell.BrandLogo.image = downloadedImage
            }catch {
                print(error)
            }
        }
    }
    
}

