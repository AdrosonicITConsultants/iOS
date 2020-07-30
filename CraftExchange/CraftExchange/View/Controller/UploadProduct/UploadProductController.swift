//
//  UploadProductController.swift
//  CraftExchange
//
//  Created by Preety Singh on 29/07/20.
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

enum NewProductState: Int {
    case addPhotos
    case addGeneralDetails
    case selectWeaveType
    case selectWarpWeftYarn
    case reedCount
    case dimensions
    case washCare
    case availability
    case weight
    case gsm
    case addDescription
}

class UploadProductViewModel {
    var productImages = Observable<[UIImage]?>(nil)
    var prodName = Observable<String?>(nil)
    var prodCode = Observable<String?>(nil)
    var prodCategory = Observable<ProductCategory?>(nil)
    var prodType = Observable<String?>(nil)
    var prodWeaveType = Observable<[String]?>(nil)
}

class UploadProductController: FormViewController {
    var currentState: NewProductState?
    var doneStates: [NewProductState] = []
    lazy var viewModel = UploadProductViewModel()
    var allCategories: Results<ProductCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.viewModel.productImages.value = []
        let realm = try! Realm()
        allCategories = realm.objects(ProductCategory.self).sorted(byKeyPath: "entityID")
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        form
        +++ Section(){ section in
            section.tag = "\(NewProductState.addPhotos.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 1, title: "Add Photos")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
            <<< CollectionViewRow() {
                $0.tag = "AddPhotoRow"
                $0.cell.collectionView.register(UINib(nibName: "ImageSelectorCell", bundle: nil), forCellWithReuseIdentifier: "ImageSelectorCell")
                $0.cell.collectionDelegate = self
                $0.cell.height = { 300.0 }
                $0.hidden = true
        }
            <<< RoundedButtonViewRow("Next1") {
                $0.tag = "Next1"
                $0.cell.titleLabel.isHidden = true
                $0.cell.compulsoryIcon.isHidden = true
                $0.cell.greyLineView.isHidden = true
                $0.cell.buttonView.borderColour = UIColor().CEGreen()
                $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
                $0.cell.buttonView.setTitleColor(.white, for: .normal)
                $0.cell.buttonView.setTitle("Next", for: .normal)
                $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = NewProductState.addPhotos.rawValue
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
                $0.hidden = true
            }
        +++ Section(){ section in
            section.tag = "\(NewProductState.addGeneralDetails.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 2, title: "Add General Details")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< RoundedTextFieldRow() {
            $0.tag = "ProdNameRow"
            $0.cell.titleLabel.text = "Name of the product(50 characters)"
            $0.cell.height = { 80.0 }
            self.viewModel.prodName.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            $0.cell.valueTextField.text = self.viewModel.prodName.value ?? ""
            self.viewModel.prodName.value = $0.cell.valueTextField.text
            $0.hidden = true
        }
        <<< RoundedTextFieldRow() {
//            $0.cell.titleLabel.text = "Product Code"
            $0.tag = "ProdCodeRow"
            $0.cell.height = { 80.0 }
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.valueTextField.placeholder = "Product Code (Eg:ABC01_02)"
            self.viewModel.prodCode.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            $0.cell.valueTextField.text = self.viewModel.prodCode.value ?? ""
            self.viewModel.prodCode.value = $0.cell.valueTextField.text
            $0.hidden = true
        }
        <<< RoundedActionSheetRow() {
            $0.tag = "ProdCatRow"
            $0.cell.titleLabel.text = "Select product category"
            $0.cell.compulsoryIcon.isHidden = true
            if let selectedCluster = self.viewModel.prodCategory.value {
                $0.cell.selectedVal = selectedCluster.prodCatDescription
            }
            $0.cell.options = allCategories?.compactMap { $0.prodCatDescription }
            $0.cell.delegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
        }.onChange({ (row) in
          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            let selectedClusterObj = self.allCategories?.filter({ (obj) -> Bool in
                obj.prodCatDescription == row.value
                }).first
            self.viewModel.prodCategory.value = selectedClusterObj
            })
        <<< RoundedActionSheetRow() {
            $0.tag = "ProdTypeRow"
            $0.cell.titleLabel.text = "Product type"
            $0.cell.compulsoryIcon.isHidden = true
            if let selectedCluster = self.viewModel.prodCategory.value {
                $0.cell.selectedVal = selectedCluster.prodCatDescription
            }
            $0.cell.options = allCategories?.compactMap { $0.prodCatDescription }
            $0.cell.delegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
        }.onChange({ (row) in
          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            let selectedClusterObj = self.allCategories?.filter({ (obj) -> Bool in
                obj.prodCatDescription == row.value
                }).first
            self.viewModel.prodCategory.value = selectedClusterObj
            })
        <<< RoundedButtonViewRow("Next2") {
            $0.tag = "Next2"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.addGeneralDetails.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.selectWeaveType.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 3, title: "Select Weave Type")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< MultipleSelectorRow<String>() {row in
            row.title = "Weave Types"
            row.options = ["Weft Ikat", "Loinloom Weaving", "Extra Weft Jamdani"]
            row.hidden = true
        }.onChange({ (row) in
            
        })
        <<< RoundedButtonViewRow("Next3") {
            $0.tag = "Next3"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.selectWeaveType.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.selectWarpWeftYarn.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 4, title: "Select Warp - Weft & Yarn")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< CollectionViewRow() {
                $0.tag = "AddWeftWarpYarnRow"
                $0.cell.collectionView.register(UINib(nibName: "DimensionsCardCell", bundle: nil), forCellWithReuseIdentifier: "DimensionsCardCell")
                $0.cell.collectionDelegate = self
                $0.cell.height = { 300.0 }
                $0.hidden = true
        }
        <<< RoundedButtonViewRow("Next4") {
            $0.tag = "Next4"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.selectWarpWeftYarn.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.reedCount.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 5, title: "Enter the reed count")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< LabelRow() {
            $0.cell.height = { 150.0 }
            $0.cell.imageView?.image = UIImage(named: "reed count")
            $0.hidden = true
        }
        <<< RoundedActionSheetRow() {
            $0.tag = "ReedCountRow"
            $0.cell.titleLabel.text = "Enter reed count"
            $0.cell.compulsoryIcon.isHidden = true
            if let selectedCluster = self.viewModel.prodCategory.value {
                $0.cell.selectedVal = selectedCluster.prodCatDescription
            }
            $0.cell.options = allCategories?.compactMap { $0.prodCatDescription }
            $0.cell.delegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
        }.onChange({ (row) in
          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            let selectedClusterObj = self.allCategories?.filter({ (obj) -> Bool in
                obj.prodCatDescription == row.value
                }).first
            self.viewModel.prodCategory.value = selectedClusterObj
            })
        <<< RoundedButtonViewRow("Next5") {
            $0.tag = "Next5"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.reedCount.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.dimensions.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 6, title: "Enter the dimensions")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< LabelRow() {
            $0.cell.height = { 150.0 }
            $0.cell.imageView?.image = UIImage(named: "dimension icon")
            $0.hidden = true
        }
        <<< lengthWidthRow() {
            $0.cell.productTitle.text = "Saree"
            $0.cell.lengthWidthDelegate = self
            $0.cell.height = { 70.0 }
            $0.hidden = true
        }
        <<< lengthWidthRow() {
            $0.cell.productTitle.text = "Blouse"
            $0.cell.lengthWidthDelegate = self
            $0.cell.height = { 70.0 }
            $0.hidden = true
        }
        <<< RoundedButtonViewRow("Next6") {
            $0.tag = "Next6"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.dimensions.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.washCare.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 7, title: "Enter the wash care instruction")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< MultipleSelectorRow<String>() {row in
            row.title = "Wash care instruction"
            row.options = ["Gentle hand wash", "Dry Clean", "Do not bleach"]
            row.hidden = true
        }.onChange({ (row) in
            
        })
        <<< RoundedButtonViewRow("Next7") {
            $0.tag = "Next7"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.washCare.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.availability.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 8, title: "Select the availability")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< OrderAvailabilityCell() {
            $0.cell.availabilityDelegate = self
            $0.hidden = true
            $0.cell.height = { 180.0 }
        }
        <<< RoundedButtonViewRow("Next8") {
            $0.tag = "Next8"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.availability.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.weight.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 9, title: "Select the weigth")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< LabelRow() {
            $0.cell.height = { 60.0 }
            $0.cell.imageView?.image = UIImage(named: "Icon weight")
            $0.hidden = true
        }
        <<< TextRow() {
            $0.title = "Saree"
            $0.hidden = true
        }
        <<< TextRow() {
            $0.title = "Blouse"
            $0.hidden = true
        }
        <<< RoundedButtonViewRow("Next9") {
            $0.tag = "Next9"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.weight.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.gsm.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 10, title: "Enter the GSM value of fabric")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< LabelRow() {
            $0.cell.height = { 60.0 }
            $0.cell.imageView?.image = UIImage(named: "GSM ")
            $0.hidden = true
        }
        <<< RoundedTextFieldRow() {
          $0.cell.titleLabel.text = "GSM"
            $0.cell.compulsoryIcon.isHidden = true
          $0.cell.height = { 80.0 }
            $0.hidden = true
//          self.viewModel.gsm.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
//          $0.cell.valueTextField.text = appDelegate?.registerUser?.buyerCompanyDetails?.companyName
//          self.viewModel.companyName.value = $0.cell.valueTextField.text
        }
        <<< RoundedButtonViewRow("Next10") {
            $0.tag = "Next10"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = NewProductState.gsm.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(NewProductState.addDescription.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 11, title: "Description")
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
        <<< TextAreaRow() {
            $0.cell.height = { 180.0 }
            $0.placeholder = "Describe your product".localized
            $0.hidden = true
        }
        <<< RoundedButtonViewRow("Next11") {
            $0.tag = "Next11"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().menuSelectorBlue()
            $0.cell.buttonView.backgroundColor = UIColor().menuSelectorBlue()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle(" Save ", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "save and upload"), for: .normal)
            $0.cell.buttonView.tintColor = .white
            $0.cell.tag = NewProductState.addDescription.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
    }
    
    @objc func expandSectionSelected(sender: UIButton) {
        expandSection(tag: sender.tag)
    }
    
    @objc func expandSection(tag: Int) {
        if currentState?.rawValue != tag {
            currentState = NewProductState.init(rawValue: tag)
            self.form.allSections .forEach { (section) in
                if section.tag == "\(tag)" {
                    section.allRows .forEach { (row) in
                        row.hidden = false
                        row.evaluateHidden()
                    }
                }else {
                    section.allRows .forEach { (row) in
                        row.hidden = true
                        row.evaluateHidden()
                    }
                }
            }
        }else {
            let section = self.form.sectionBy(tag: "\(tag)")
            section?.allRows .forEach { (row) in
                row.hidden = true
                row.evaluateHidden()
            }
            currentState = nil
        }
    }
    
    func createSectionView(forStep:Int, title:String) -> UIView {
        let ht: CGFloat = 60.0
        let width: CGFloat = self.view.frame.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: ht))
          let y = 5
          let lblHt = 40
          let dotView = UIView(frame: CGRect(x: 20, y: 15, width: 20, height: 20))
        dotView.backgroundColor = self.doneStates.contains(NewProductState.addPhotos) ? UIColor().CEGreen() : .red
          dotView.layer.cornerRadius = 10
          view.addSubview(dotView)
        
          let stepLbl = UILabel.init(frame: CGRect(x: dotView.frame.origin.x + dotView.frame.size.width + 5, y: CGFloat(y), width: CGFloat(70), height: CGFloat(lblHt)))
          stepLbl.font = .systemFont(ofSize: 17, weight: .regular)
          stepLbl.textColor = .darkGray
          stepLbl.text = "Step \(forStep):".localized
          view.addSubview(stepLbl)
          
          let stepTitle = UILabel.init(frame: CGRect(x: stepLbl.frame.origin.x + stepLbl.frame.size.width + 5, y: CGFloat(y), width: CGFloat(250), height: CGFloat(lblHt)))
          stepTitle.font = .systemFont(ofSize: 17, weight: .medium)
          stepTitle.textColor = .black
          stepTitle.text = title.localized
          view.addSubview(stepTitle)
        
          let arrow = UIButton.init(type: .custom)
          arrow.setImage(UIImage(named: "arrow-down"), for: .normal)
          arrow.addTarget(self, action: #selector(expandSectionSelected(sender:)), for: .touchUpInside)
          arrow.tintColor = .lightGray
          arrow.tag = forStep-1
          arrow.frame = CGRect(x: view.frame.width - 40, y: 15, width: 20, height: 20)
          view.addSubview(arrow)
        return view
    }
    
}

extension UploadProductController: ButtonActionProtocol, DimensionCellProtocol, LengthWidthCellProtocol, AvailabilityCellProtocol {
    func lengthWidthSelected(tag: Int) {
        print("tag: \(tag)")
    }
    
    func customButtonSelected(tag: Int) {
        expandSection(tag: tag+1)
    }
    
    func showOption(tag: Int) {
        print("option")
    }
    
    func availabilitySelected(tag: Int) {
        print(tag)
    }
}

extension UploadProductController: UICollectionViewDelegate, UICollectionViewDataSource, AddImageProtocol {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentState == NewProductState.selectWarpWeftYarn {
            return 3
        }
        if let count = viewModel.productImages.value?.count {
            if count == 3 {
                return 3
            }else {
                return count+1
            }
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentState == NewProductState.selectWarpWeftYarn {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DimensionsCardCell",
            for: indexPath) as! DimensionsCardCell
            cell.dimensionDelegate = self
            cell.layer.borderWidth = 0.0
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.masksToBounds = false
            switch indexPath.row {
            case 0:
                print("Add Warp")
                cell.cardImg.image = UIImage.init(named: "warp")
                cell.cardTitle.text = "Warp".localized
                cell.option1 = ["Warp Yarn 1", "Warp Yarn 2", "Warp Yarn 3"]
                cell.option2 = ["Warp Count 1", "Warp Count 2", "Warp Count 3"]
                cell.option3 = ["Warp Dyed 1", "Warp Dyed 2", "Warp Dyed 3"]
                cell.optionalLbl.isHidden = true
            case 1:
                print("Add Weft")
                cell.cardImg.image = UIImage.init(named: "weft")
                cell.cardTitle.text = "Weft".localized
                cell.option1 = ["Weft Yarn 1", "Weft Yarn 2", "Weft Yarn 3"]
                cell.option2 = ["Weft Count 1", "Weft Count 2", "Weft Count 3"]
                cell.option3 = ["Weft Dyed 1", "Weft Dyed 2", "Weft Dyed 3"]
                cell.optionalLbl.isHidden = true
            case 2:
                print("Add Extra Weft")
                cell.cardImg.image = UIImage.init(named: "extra weft")
                cell.cardTitle.text = "Extra Weft".localized
                cell.option1 = ["ExWeft Yarn 1", "ExWeft Yarn 2", "ExWeft Yarn 3"]
                cell.option2 = ["ExWeft Count 1", "ExWeft Count 2", "ExWeft Count 3"]
                cell.option3 = ["ExWeft Dyed 1", "ExWeft Dyed 2", "ExWeft Dyed 3"]
                cell.optionalLbl.isHidden = false
            default:
                print("")
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSelectorCell",
                                                      for: indexPath) as! ImageSelectorCell
        var showDefaultCell = false
        if let count = viewModel.productImages.value?.count, viewModel.productImages.value?.count ?? 0 > 0 {
            if count == 3 {
                showDefaultCell = false
            }else {
                if indexPath.row == count {
                    showDefaultCell = true
                }else {
                    showDefaultCell = false
                }
            }
        }else {
            showDefaultCell = true
        }
        if showDefaultCell {
            cell.addImageButton.setImage(UIImage.init(named: "Add photo"), for: .normal)
            cell.addImageButton.isUserInteractionEnabled = true
            cell.deleteImageButton.isHidden = true
            cell.deleteImageButton.isUserInteractionEnabled = false
            cell.editImageButton.isHidden = true
            cell.editImageButton.isUserInteractionEnabled = false
            cell.lineView.isHidden = true
        }else {
            cell.addImageButton.setImage(viewModel.productImages.value?[indexPath.row], for: .normal)
            cell.addImageButton.isUserInteractionEnabled = false
            cell.deleteImageButton.isHidden = false
            cell.deleteImageButton.isUserInteractionEnabled = true
            cell.deleteImageButton.tag = indexPath.row
            cell.editImageButton.isHidden = false
            cell.editImageButton.isUserInteractionEnabled = true
            cell.lineView.isHidden = false
        }
        cell.delegate = self
        return cell
    }
    
    @objc func addImageSelected() {
        self.showImagePickerAlert()
    }
    
    func deleteImageSelected(atIndex: Int) {
        self.viewModel.productImages.value?.remove(at: atIndex)
        reloadAddPhotoRow()
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "AddPhotoRow") as? CollectionViewRow
        row?.reload()
        row?.cell.collectionView.reloadData()
    }
}

extension UploadProductController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        if let compressedImg = selectedImage.resizedTo1MB() {
            self.viewModel.productImages.value?.append(compressedImg)
        }else {
            self.viewModel.productImages.value?.append(selectedImage)
        }
        picker.dismiss(animated: true) {
            self.reloadAddPhotoRow()
        }
    }
}
/*
extension UploadProductController: iCarouselDelegate, iCarouselDataSource {
  func numberOfItems(in carousel: iCarousel) -> Int {
    if let count = viewModel.productImages.value?.count {
        if count == 3 {
            return 3
        }else {
            return count+1
        }
    }
    return 1
  }
  
  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    
    var outerView = self.view.viewWithTag(1001)
    var addProductBtn = view?.viewWithTag(201) as? UIButton
    var lineView = view?.viewWithTag(202)
    if outerView == nil {
        outerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 280, height: 280))
        outerView?.backgroundColor = .black
        outerView?.tag = 1001
        
        addProductBtn = UIButton.init(type: .custom)
        addProductBtn?.tag = 201
        addProductBtn?.setImage(UIImage.init(named: "Add photo"), for: .normal)
        addProductBtn?.addTarget(self, action: #selector(addProductSelected(sender:)), for: .touchUpInside)
        addProductBtn?.frame = CGRect.init(x: 20, y: 10, width: 200, height: 200)
        outerView?.addSubview(addProductBtn!)
        
        lineView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 40))
        lineView?.backgroundColor = .white
        lineView?.center = CGPoint.init(x: outerView?.center.x ?? 0, y: (addProductBtn?.frame.origin.y ?? 0) + (addProductBtn?.frame.size.height ?? 0) + 20)
        lineView?.tag = 201
        outerView?.addSubview(lineView!)
        
        
    }
        
    
    
    return outerView ?? UIView()
  }
    
    @objc func addProductSelected(sender: UIButton) {
        
    }
  
  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    if (option == .spacing)
    {
      return value * 1.1;
    }
    return value
  }
  
}
*/
