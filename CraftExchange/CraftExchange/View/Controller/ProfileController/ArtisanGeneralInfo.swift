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

class ArtisanGeneralInfoViewModel {
  var addr1 = Observable<String?>(nil)
  var district = Observable<String?>(nil)
  var state = Observable<String?>(nil)
  var country = Observable<String?>(nil)
  var pincode = Observable<String?>(nil)
    var profileImageData = Observable<(Data,String)?>(nil)
}

class ArtisanGeneralInfo: FormViewController, ButtonActionProtocol {
    var editEnabled = false
    var viewModel = ArtisanGeneralInfoViewModel()
    var allCountries: Results<Country>?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfilePic), name: NSNotification.Name("loadProfileImage"), object: nil)
        self.view.backgroundColor = .white
        let realm = try! Realm()
        allCountries = realm.objects(Country.self).sorted(byKeyPath: "entityID")
        let parentVC = self.parent as? BuyerProfileController
        
        form +++
            Section()
            <<< ProfileImageRow() {
                $0.cell.height = { 180.0 }
                $0.cell.delegate = self
                $0.tag = "ProfileView"
                if let _ = User.loggedIn()?.profilePicUrl, let name = User.loggedIn()?.profilePic {
                    do {
                        let downloadedImage = try Disk.retrieve("\(User.loggedIn()?.entityID ?? 84)/\(name)", from: .caches, as: UIImage.self)
                        $0.cell.actionButton.setImage(downloadedImage, for: .normal)
                    }catch {
                        print(error)
                    }
                    if parentVC?.reachabilityManager?.connection != .unavailable {
                        updateArtisanProfilePic()
                    }
                } else if parentVC?.reachabilityManager?.connection != .unavailable {
                    updateArtisanProfilePic()
                } else {
                    $0.cell.actionButton.setImage(UIImage.init(named: "user"), for: .normal)
                }
            }.cellUpdate({ (cell, row) in
                if self.editEnabled {
                    cell.isUserInteractionEnabled = true
                    cell.actionButton.isUserInteractionEnabled = true
                }else {
                    cell.isUserInteractionEnabled = false
                    cell.actionButton.isUserInteractionEnabled = false
                }
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
            +++ Section() {
                $0.tag = "EditAddressSection"
                $0.hidden = true
            }
            <<< TextRow() {
                $0.tag = "AddressEditRow1"
                $0.title = "Address Line 1".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.line1 ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                self.viewModel.addr1.value = $0.cell.textField.text
                self.viewModel.addr1.bidirectionalBind(to: $0.cell.textField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    self.viewModel.addr1.value = cell.textField.text
                })
            <<< TextRow() {
                $0.tag = "AddressEditRow2"
                $0.title = "District".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.district ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                self.viewModel.district.value = $0.cell.textField.text
                self.viewModel.district.bidirectionalBind(to: $0.cell.textField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    self.viewModel.district.value = cell.textField.text
                })
            <<< TextRow() {
                $0.tag = "AddressEditRow3"
                $0.title = "State".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.state ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                self.viewModel.state.value = $0.cell.textField.text
                self.viewModel.state.bidirectionalBind(to: $0.cell.textField.reactive.text)
                }.cellUpdate({ (cell, row) in
                    self.viewModel.state.value = cell.textField.text
                })
            <<< TextRow() {
                $0.tag = "AddressEditRow4"
                $0.title = "Pincode".localized
                var addressString = ""
                User.loggedIn()?.addressList .forEach({ (address) in
                    if address.addressType?.entityID == 1 {
                        addressString = address.pincode ?? ""
                    }
                })
                $0.cell.textField.text = addressString
                self.viewModel.pincode.value = $0.cell.textField.text
                self.viewModel.pincode.bidirectionalBind(to: $0.cell.textField.reactive.text)
            }.cellUpdate({ (cell, row) in
                self.viewModel.pincode.value = cell.textField.text
            })
            <<< ActionSheetRow<String>() { row in
                row.tag = "AddressEditRow5"
                row.title = "Country"
                row.cell.height = { 80.0 }
                row.options = allCountries?.compactMap { $0.name }
            }.cellUpdate({ (cell, row) in
                row.cell.textLabel?.text = "Country".localized
                self.viewModel.country.value = row.value
            })
            +++ Section()
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
    
    func updateArtisanProfilePic() {
        if let name = User.loggedIn()?.profilePic, let userID = User.loggedIn()?.entityID {
            let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/User/\(userID)/ProfilePics/\(name)")
            URLSession.shared.dataTask(with: url!) { data, response, error in
                // do your stuff here...
                DispatchQueue.main.async {
                    // do something on the main queue
                    if error == nil {
                        if let finalData = data {
                            User.loggedIn()?.saveOrUpdateProfileImage(data: finalData)
                            NotificationCenter.default.post(name: Notification.Name("loadProfileImage"), object: nil)
                        }
                    }
                }
            }.resume()
        }
    }
    
    func customButtonSelected(tag: Int) {
        //Edit selected
        let btnRow = self.form.rowBy(tag: "EditArtisanDetails") as? RoundedButtonViewRow
        let secRow = self.form.sectionBy(tag: "EditAddressSection")
        if btnRow?.cell.buttonView.titleLabel?.text == "Edit your details" {
            editEnabled = true
            secRow?.hidden = false
            secRow?.evaluateHidden()
            btnRow?.cell.buttonView.setTitle("Save your details", for: .normal)
            btnRow?.cell.buttonView.borderColour = .red
            btnRow?.cell.buttonView.backgroundColor = .red
        }else {
            editEnabled = false
            secRow?.hidden = true
            secRow?.evaluateHidden()
            btnRow?.cell.buttonView.setTitle("Edit your details", for: .normal)
            btnRow?.cell.buttonView.borderColour = .black
            btnRow?.cell.buttonView.backgroundColor = .black
            if let parentVC = self.parent as? BuyerProfileController {
                let selectedCountryObj = self.allCountries?.filter("%K == %@", "name", self.viewModel.country.value).first
                let newAddr = LocalAddress.init(id: User.loggedIn()?.addressList.first?.entityID ?? 0, addrType: (1,"Registered"), country: (countryId: selectedCountryObj?.entityID, countryName: selectedCountryObj?.name) as? (countryId: Int, countryName: String), city: nil, district: self.viewModel.district.value, landmark: nil, line1: self.viewModel.addr1.value, line2: nil, pincode: self.viewModel.pincode.value, state: self.viewModel.state.value , street: nil, userId: User.loggedIn()?.entityID ?? 0)
                if self.viewModel.profileImageData.value != nil {
                    parentVC.viewModel.updateArtisanProfile?(newAddr.toJSON(),self.viewModel.profileImageData.value?.0,self.viewModel.profileImageData.value?.1)
                }else {
                    parentVC.viewModel.updateArtisanProfile?(newAddr.toJSON(),nil,nil)
                }
                
            }
        }
        let profileRow = self.form.rowBy(tag: "ProfileView")
        profileRow?.updateCell()
    }
    
    @objc func updateProfilePic() {
        if let _ = User.loggedIn()?.profilePicUrl, let name = User.loggedIn()?.profilePic, let userID = User.loggedIn()?.entityID {
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

extension ArtisanGeneralInfo: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        self.viewModel.profileImageData.value = (imgdata, "profilePic.jpg") as? (Data, String)
        
        picker.dismiss(animated: true, completion: nil)
    }
}
