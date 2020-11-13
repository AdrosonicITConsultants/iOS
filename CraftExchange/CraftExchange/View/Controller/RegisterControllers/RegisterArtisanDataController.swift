//
//  RegisterArtisanDataController.swift
//  CraftExchange
//
//  Created by Preety Singh on 02/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

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

class ArtisanDataViewModel {
  var firstname = Observable<String?>(nil)
  var lastname = Observable<String?>(nil)
  var pincode = Observable<String?>(nil)
//  var selectedProdCat = Observable<[Int]?>(nil)
  var district = Observable<String?>(nil)
  var state = Observable<String?>(nil)
  var mobNo = Observable<String?>(nil)
  var panNo = Observable<String?>(nil)
  var addr = Observable<String?>(nil)
  var selectedClusterId = Observable<Int?>(nil)
  var nextSelected: (() -> Void)?
  var viewDidAppear: (() -> Void)?
}

class RegisterArtisanDataController: FormViewController {
  
  let viewModel = ArtisanDataViewModel()
  var weaverID: String?
  var allClusters: [ClusterDetails]?
    
  override func viewDidLoad() {
    super.viewDidLoad()
//      DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
    self.navigationItem.rightBarButtonItem = roleBarButton()
    self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    self.form +++
      Section()
    <<< LabelRow() {
      $0.cell.height = { 220.0 }
      $0.cell.imageView?.frame = $0.cell.contentView.frame
      $0.cell.imageView?.image = UIImage(named: "logo-underlying-text")
    }
    <<< LabelRow() {
      $0.title = "Artisan id: \(self.weaverID ?? "")"
      $0.cellStyle = .default
      $0.cell.textLabel?.textAlignment = .center
      $0.cell.textLabel?.textColor = .darkGray
      $0.cell.textLabel?.font = UIFont.systemFont(ofSize: 20)
      $0.cell.height = { 40.0 }
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "First name".localized
      $0.cell.height = { 80.0 }
      self.viewModel.firstname.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.firstName
        self.viewModel.firstname.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Last name".localized
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.height = { 80.0 }
      self.viewModel.lastname.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.lastName
        self.viewModel.lastname.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Pincode".localized
      $0.cell.height = { 80.0 }
      self.viewModel.pincode.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.pincode
        self.viewModel.pincode.value = $0.cell.valueTextField.text
    }
    <<< RoundedActionSheetRow() {
        $0.tag = "ClusterRow"
    $0.cell.titleLabel.text = "Cluster".localized
        if let selectedCluster = appDelegate?.registerUser?.clusterId {
            $0.cell.selectedVal = allClusters?.first(where: { (obj) -> Bool in
                obj.entityID == selectedCluster
                })?.clusterDescription
        }
    $0.cell.options = allClusters?.compactMap { $0.clusterDescription }
    $0.cell.delegate = self
    $0.add(rule: RuleRequired())
    $0.cell.height = { 80.0 }
    }.onChange({ (row) in
      print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
        let selectedClusterObj = self.allClusters?.filter({ (obj) -> Bool in
            obj.clusterDescription == row.value
            }).first
        self.viewModel.selectedClusterId.value = selectedClusterObj?.entityID
        })
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "District".localized
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.district.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.district
        self.viewModel.district.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "State".localized
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.state.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.state
        self.viewModel.state.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Mobile Number".localized
      $0.cell.height = { 80.0 }
      self.viewModel.mobNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.mobile
        self.viewModel.mobNo.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Pan No.".localized
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      $0.cell.valueTextField.autocapitalizationType = .allCharacters
      self.viewModel.panNo.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.pancard
        self.viewModel.panNo.value = $0.cell.valueTextField.text
    }
    <<< RoundedTextFieldRow() {
      $0.cell.titleLabel.text = "Address".localized
      $0.cell.height = { 80.0 }
      $0.cell.compulsoryIcon.isHidden = true
      self.viewModel.addr.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
        $0.cell.valueTextField.text = appDelegate?.registerUser?.address?.line1
        self.viewModel.addr.value = $0.cell.valueTextField.text
    }
      <<< RoundedButtonViewRow("REGNextCell") {
        $0.cell.titleLabel.text = "Fields are mandatory".localized
        $0.cell.compulsoryIcon.isHidden = false
        $0.cell.greyLineView.isHidden = false
        $0.cell.buttonView.borderColour = .black
        $0.cell.buttonView.backgroundColor = .black
        $0.cell.buttonView.setTitleColor(.white, for: .normal)
        $0.cell.buttonView.setTitle("Next".localized, for: .normal)
        $0.cell.tag = 101
        $0.cell.delegate = self
        $0.cell.height = { 100.0 }
    }
    <<< RoundedButtonViewRow("REGHelpCell") {
        $0.cell.titleLabel.text = "In case of any help".localized
        $0.cell.compulsoryIcon.isHidden = true
        $0.cell.greyLineView.isHidden = true
        $0.cell.buttonView.borderColour = .black
        $0.cell.buttonView.backgroundColor = .white
        $0.cell.buttonView.setTitleColor(.black, for: .normal)
        $0.cell.buttonView.setTitle("Reach out to us".localized, for: .normal)
        $0.cell.tag = 102
        $0.cell.delegate = self
        $0.cell.height = { 100.0 }
    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.viewModel.viewDidAppear?()
    }

}

extension RegisterArtisanDataController: ButtonActionProtocol {
  func customButtonSelected(tag: Int) {
    switch tag {
    case 101:
      print("Next Selected")
      self.viewModel.nextSelected?()
    case 102:
      alert("For any query reach us @ antaran@tatatrusts.org")
    default:
      print("do nothing")
    }
  }
}
