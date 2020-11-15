//
//  UploadCustomProductController.swift
//  CraftExchange
//
//  Created by Preety Singh on 14/08/20.
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

enum CustomProductState: Int {
    case addPhotos
    case addGeneralDetails
    case selectWeaveType
    case selectWarpWeftYarn
    case reedCount
    case dimensions
    case gsm
    case addDescription
}

class UploadCustProductViewModel {
    var productImages = Observable<[UIImage]?>(nil)

    var prodCategory = Observable<ProductCategory?>(nil)
    var prodType = Observable<ProductType?>(nil)
    
    var prodWeaveType = Observable<[Weave]?>(nil)
    
    var warpYarn = Observable<Yarn?>(nil)
    var weftYarn = Observable<Yarn?>(nil)
    var exWeftYarn = Observable<Yarn?>(nil)
    var warpYarnCnt = Observable<YarnCount?>(nil)
    var weftYarnCnt = Observable<YarnCount?>(nil)
    var exWeftYarnCnt = Observable<YarnCount?>(nil)
    var warpDye = Observable<Dye?>(nil)
    var weftDye = Observable<Dye?>(nil)
    var exWeftDye = Observable<Dye?>(nil)
    var custWarpYarnCnt = Observable<String?>(nil)
    var custWeftYarnCnt = Observable<String?>(nil)
    var custExWeftYarnCnt = Observable<String?>(nil)
    
    var reedCount = Observable<ReedCount?>(nil)
    
    var prodLength = Observable<String?>(nil)
    var prodWidth = Observable<String?>(nil)
    var relatedProdLength = Observable<String?>(nil)
    var relatedProdWidth = Observable<String?>(nil)

    var gsm = Observable<String?>(nil)
    var prodDescription = Observable<String?>(nil)
    
    var saveProductSelected: (() -> Void)?
    var deleteProductSelected: (() -> Void)?
}

class UploadCustomProductController: FormViewController {
    var currentState: CustomProductState?
    var doneStates: [CustomProductState] = []
    lazy var viewModel = UploadCustProductViewModel()
    var allCategories: Results<ProductCategory>?
    var allWeaves: Results<Weave>?
    var allYarns: Results<Yarn>?
    var allDye: Results<Dye>?
    var allReed: Results<ReedCount>?
    var product: CustomProduct?
    var viewWillAppear: (() -> ())?
    var fromEnquiry = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.viewModel.productImages.value = []
        self.viewModel.prodWeaveType.value = []
        let realm = try! Realm()
        allCategories = realm.objects(ProductCategory.self).sorted(byKeyPath: "entityID")
        allWeaves = realm.objects(Weave.self).sorted(byKeyPath: "entityID")
        allYarns = realm.objects(Yarn.self).sorted(byKeyPath: "entityID")
        allDye = realm.objects(Dye.self).sorted(byKeyPath: "entityID")
        allReed = realm.objects(ReedCount.self).sorted(byKeyPath: "entityID")
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        let back = UIBarButtonItem(image: UIImage.init(systemName: "arrow.left"), style: .done, target: self, action: #selector(backSelected(_:)))
        back.tintColor = .darkGray
        self.navigationItem.leftBarButtonItem =  back
        
        let weaveTypeSection = Section(){ section in
            section.tag = "\(CustomProductState.selectWeaveType.rawValue)"
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

        if let productObj = product {
            viewWillAppear?()
            if fromEnquiry == false {
                let rightButtonItem = UIBarButtonItem.init(title: "Delete", style: .plain, target: self, action: #selector(deleteClicked))
                rightButtonItem.tintColor = .red
                
                let rightButtonItem2 = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveClicked))
                
                self.navigationItem.rightBarButtonItems = [rightButtonItem, rightButtonItem2]
            }
            
            viewModel.prodType.value = ProductType.getProductType(searchId: productObj.productTypeId)
            viewModel.prodCategory.value = ProductCategory.getProductCat(catId: productObj.productCategoryId)
            productObj.weaves.forEach { (type) in
                if let obj = Weave.getWeaveType(searchId: type.weaveId) {
                    viewModel.prodWeaveType.value?.append(obj)
                }
            }
            viewModel.warpYarn.value = Yarn.getYarn(searchId: productObj.warpYarnId)
            viewModel.weftYarn.value = Yarn.getYarn(searchId: productObj.weftYarnId)
            viewModel.exWeftYarn.value = Yarn.getYarn(searchId: productObj.extraWeftYarnId)
            viewModel.warpDye.value = Dye.getDyeType(searchId: productObj.warpDyeId)
            viewModel.weftDye.value = Dye.getDyeType(searchId: productObj.weftDyeId)
            viewModel.exWeftDye.value = Dye.getDyeType(searchId: productObj.extraWeftDyeId)
            if viewModel.warpYarn.value?.yarnType.first?.manual == true {
                viewModel.custWarpYarnCnt.value = productObj.warpYarnCount
            }else {
                viewModel.warpYarnCnt.value = YarnCount.getYarnCount(forType: viewModel.warpYarn.value?.yarnType.first?.entityID ?? 0, searchString: productObj.warpYarnCount ?? "0")
            }
            if viewModel.weftYarn.value?.yarnType.first?.manual == true {
                viewModel.custWeftYarnCnt.value = productObj.weftYarnCount
            }else {
                viewModel.weftYarnCnt.value = YarnCount.getYarnCount(forType: viewModel.weftYarn.value?.yarnType.first?.entityID ?? 0, searchString: productObj.weftYarnCount ?? "0")
            }
            if viewModel.exWeftYarn.value?.yarnType.first?.manual == true {
                viewModel.custExWeftYarnCnt.value = productObj.extraWeftYarnCount
            }else {
                viewModel.exWeftYarnCnt.value = YarnCount.getYarnCount(forType: viewModel.exWeftYarn.value?.yarnType.first?.entityID ?? 0, searchString: productObj.extraWeftYarnCount ?? "0")
            }
            viewModel.reedCount.value = ReedCount.getReedCount(searchId: productObj.reedCountId)

            viewModel.prodLength.value = productObj.length
            viewModel.prodWidth.value = productObj.width
            viewModel.relatedProdLength.value = productObj.relatedProducts.first?.length
            viewModel.relatedProdWidth.value = productObj.relatedProducts.first?.width
            viewModel.gsm.value = productObj.gsm
            viewModel.prodDescription.value = productObj.productSpec
//            downloadProdImages()
        }
        else {
            let rightButtonItem = UIBarButtonItem.init(title: "Save", style: .plain, target: self, action: #selector(saveClicked))
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
        
        var strArr:[String] = []
        if product != nil {
            product?.weaves .forEach({ (weave) in
                strArr.append("\(Weave.getWeaveType(searchId: weave.weaveId)?.weaveDesc ?? "")")
            })
        }
        
        if let setWeave = allWeaves?.compactMap({$0}) {
            setWeave.forEach({ (weave) in
                weaveTypeSection <<< ToggleOptionRow() {
                    $0.cell.height = { 45.0 }
                    $0.cell.titleLbl.text = weave.weaveDesc
                    if strArr.contains(weave.weaveDesc ?? "") {
                        $0.cell.titleLbl.textColor = UIColor().menuSelectorBlue()
                        $0.cell.toggleButton.setImage(UIImage.init(named: "blue tick"), for: .normal)
                    }else {
                        $0.cell.titleLbl.textColor = .lightGray
                        $0.cell.toggleButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
                    }
                    $0.cell.washCare = false
                    $0.cell.toggleDelegate = self
                    $0.cell.toggleButton.tag = weave.entityID
                    $0.hidden = true
                    if fromEnquiry {
                        $0.cell.isUserInteractionEnabled = false
                    }
                }.onCellSelection({ (cell, row) in
                    cell.toggleButton.sendActions(for: .touchUpInside)
                    cell.contentView.backgroundColor = .white
                })
            })
        }
        
        form
        +++ Section(){ section in
            section.tag = "\(CustomProductState.addPhotos.rawValue)"
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
                $0.cell.buttonView.setTitle("Next".localized, for: .normal)
                $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
                $0.cell.tag = CustomProductState.addPhotos.rawValue
                $0.cell.height = { 80.0 }
                $0.cell.delegate = self
                $0.hidden = true
            }
        +++ Section(){ section in
            section.tag = "\(CustomProductState.addGeneralDetails.rawValue)"
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
        <<< RoundedActionSheetRow() {
            $0.tag = "ProdCatRow"
            $0.cell.titleLabel.text = "Select product category".localized
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.options = allCategories?.compactMap { $0.prodCatDescription }
            if let selectedCluster = self.viewModel.prodCategory.value {
                $0.cell.selectedVal = selectedCluster.prodCatDescription
                $0.value = selectedCluster.prodCatDescription
            }
            $0.cell.actionButton.setTitle($0.value, for: .normal)
            $0.cell.delegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.onChange({ (row) in
          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            let selectedClusterObj = self.allCategories?.filter({ (obj) -> Bool in
                obj.prodCatDescription == row.value
                }).first
            self.viewModel.prodCategory.value = selectedClusterObj
            
            let typeRow = self.form.rowBy(tag: "ProdTypeRow") as! RoundedActionSheetRow
            typeRow.cell.options = selectedClusterObj?.productTypes.compactMap { $0.productDesc }
            typeRow.value = nil
            self.viewModel.prodType.value = nil
            typeRow.cell.actionButton.setTitle("", for: .normal)
        }).cellSetup({ (cell, row) in
            if let selectedCluster = self.viewModel.prodCategory.value {
                cell.selectedVal = selectedCluster.prodCatDescription
                cell.row.value = selectedCluster.prodCatDescription
            }
            cell.actionButton.setTitle(cell.row.value, for: .normal)
        })
        <<< RoundedActionSheetRow() {
            $0.tag = "ProdTypeRow"
            $0.cell.titleLabel.text = "Product type".localized
            $0.cell.compulsoryIcon.isHidden = true
            if let selectedCat = self.viewModel.prodCategory.value {
                $0.cell.options = selectedCat.productTypes.compactMap { $0.productDesc }
            }
            if let selectedProdType = self.viewModel.prodType.value {
                $0.cell.selectedVal = selectedProdType.productDesc
                $0.value = selectedProdType.productDesc
            }
            $0.cell.actionButton.setTitle($0.value, for: .normal)
            $0.cell.delegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.onChange({ (row) in
          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            let selectedTypeObj = self.viewModel.prodCategory.value?.productTypes.filter({ (obj) -> Bool in
                obj.productDesc == row.value
            }).first
            self.viewModel.prodType.value = selectedTypeObj
            self.viewModel.prodLength.value = nil
            self.viewModel.prodWidth.value = nil
            self.viewModel.relatedProdLength.value = nil
            self.viewModel.relatedProdWidth.value = nil
            self.viewModel.gsm.value = nil
            let row = self.form.rowBy(tag: "ProdLenWidthRow") as! lengthWidthRow
            row.cell.lengthTextField.text = nil
            row.cell.widthTextField.text = nil
            row.cell.length.setTitle("Select length".localized, for: .normal)
            row.cell.width.setTitle("Select width".localized, for: .normal)
            let row2 = self.form.rowBy(tag: "RelatedProdLenWidthRow") as! lengthWidthRow
            row2.cell.lengthTextField.text = nil
            row2.cell.widthTextField.text = nil
            row2.cell.length.setTitle("Select length".localized, for: .normal)
            row2.cell.width.setTitle("Select width".localized, for: .normal)
            let row5 = self.form.rowBy(tag: "GSMRow") as! RoundedTextFieldRow
            row5.value = nil
            row5.cell.valueTextField.text = nil
            let section = self.form.sectionBy(tag: "\(CustomProductState.gsm.rawValue)")
            if self.viewModel.prodCategory.value?.prodCatDescription == "Fabric" {
                section?.hidden = false
            }else {
                section?.hidden = true
            }
            section?.evaluateHidden()
        })
        <<< RoundedButtonViewRow("Next2") {
            $0.tag = "Next2"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next".localized, for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = CustomProductState.addGeneralDetails.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ weaveTypeSection
        <<< RoundedButtonViewRow("Next3") {
            $0.tag = "Next3"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next".localized, for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = CustomProductState.selectWeaveType.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(CustomProductState.selectWarpWeftYarn.rawValue)"
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
            $0.cell.buttonView.setTitle("Next".localized, for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = CustomProductState.selectWarpWeftYarn.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(CustomProductState.reedCount.rawValue)"
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
        <<< ImageViewRow() {
            $0.cell.height = { 120.0 }
            $0.cell.cellImage.image = UIImage(named: "reed count")
            $0.hidden = true
        }
        <<< RoundedActionSheetRow() {
            $0.tag = "ReedCountRow"
            $0.cell.titleLabel.text = "Enter reed count".localized
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.options = allReed?.compactMap({$0.count})
            if let selectedObj = self.viewModel.reedCount.value {
                $0.cell.selectedVal = selectedObj.count
                $0.value = selectedObj.count
            }
            $0.cell.actionButton.setTitle($0.value, for: .normal)
            $0.cell.delegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.onChange({ (row) in
          print("row: \(row.indexPath?.row ?? 100) \(row.value ?? "blank")")
            row.cell.options = self.allReed?.compactMap { $0.count }
            let selectedObj = self.allReed?.filter({ (obj) -> Bool in
                obj.count == row.value
                }).first
            self.viewModel.reedCount.value = selectedObj
        })
        <<< RoundedButtonViewRow("Next5") {
            $0.tag = "Next5"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next".localized, for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = CustomProductState.reedCount.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(CustomProductState.dimensions.rawValue)"
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
        <<< ImageViewRow() {
            $0.cell.height = { 120.0 }
            $0.cell.cellImage.image = UIImage(named: "dimension icon")
            $0.hidden = true
        }
        <<< lengthWidthRow() {
            $0.tag = "ProdLenWidthRow"
            $0.cell.productTitle.text = self.viewModel.prodType.value?.productDesc ?? ""
            $0.cell.lengthWidthDelegate = self
            $0.cell.height = { 80.0 }
            $0.cell.length.tag = 1001
            $0.cell.width.tag = 1002
            $0.hidden = true
            self.viewModel.prodLength.bidirectionalBind(to: $0.cell.lengthTextField.reactive.text)
            $0.cell.lengthTextField.text = self.viewModel.prodLength.value ?? ""
            self.viewModel.prodWidth.bidirectionalBind(to: $0.cell.widthTextField.reactive.text)
            $0.cell.widthTextField.text = self.viewModel.prodWidth.value ?? ""
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.cellUpdate({ (cell, row) in
            cell.productTitle.text = self.viewModel.prodType.value?.productDesc ?? ""
            cell.option1 = self.viewModel.prodType.value?.productLengths.compactMap({$0.length})
            cell.option2 = self.viewModel.prodType.value?.productWidths.compactMap({$0.width})
            if self.viewModel.prodType.value?.productLengths.count ?? 0 > 0 {
                cell.length.isHidden = false
                cell.length.isUserInteractionEnabled = true
                cell.lengthTextField.isHidden = true
            }else {
                cell.length.isHidden = true
                cell.length.isUserInteractionEnabled = false
                cell.lengthTextField.isHidden = false
            }
            if self.viewModel.prodType.value?.productWidths.count ?? 0 > 0 {
                cell.width.isHidden = false
                cell.width.isUserInteractionEnabled = true
                cell.widthTextField.isHidden = true
            }else {
                cell.width.isHidden = true
                cell.width.isUserInteractionEnabled = false
                cell.widthTextField.isHidden = false
            }
            cell.length.setTitle(self.viewModel.prodLength.value, for: .normal)
            cell.width.setTitle(self.viewModel.prodWidth.value, for: .normal)
            cell.lengthTextField.text = self.viewModel.prodLength.value ?? ""
            cell.widthTextField.text = self.viewModel.prodWidth.value ?? ""
        })
        <<< lengthWidthRow() {
            $0.tag = "RelatedProdLenWidthRow"
            $0.cell.productTitle.text = self.viewModel.prodType.value?.relatedProductTypes.first?.productDesc ?? ""
            $0.cell.lengthWidthDelegate = self
            $0.cell.height = { 80.0 }
            $0.hidden = true
            $0.cell.length.tag = 2001
            $0.cell.width.tag = 2002
            self.viewModel.relatedProdLength.bidirectionalBind(to: $0.cell.lengthTextField.reactive.text)
            $0.cell.lengthTextField.text = self.viewModel.relatedProdLength.value ?? ""
            self.viewModel.relatedProdLength.value = $0.cell.lengthTextField.text
            self.viewModel.relatedProdWidth.bidirectionalBind(to: $0.cell.widthTextField.reactive.text)
            $0.cell.widthTextField.text = self.viewModel.relatedProdWidth.value ?? ""
            self.viewModel.relatedProdWidth.value = $0.cell.widthTextField.text
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.cellUpdate({ (cell, row) in
            cell.productTitle.text = self.viewModel.prodType.value?.relatedProductTypes.first?.productDesc ?? ""
            if self.viewModel.prodType.value?.relatedProductTypes.count ?? 0 > 0 {
                cell.height = { 70.0 }
            }else {
                cell.height = { 0.0 }
            }
            if let type = self.viewModel.prodType.value?.relatedProductTypes.first {
                cell.option1 = type.productLengths.compactMap({$0.length})
                cell.option2 = type.productWidths.compactMap({$0.width})
                if type.productLengths.count > 0 {
                    cell.length.isHidden = false
                    cell.length.isUserInteractionEnabled = true
                    cell.lengthTextField.isHidden = true
                }else {
                    cell.length.isHidden = true
                    cell.length.isUserInteractionEnabled = false
                    cell.lengthTextField.isHidden = false
                }
                if type.productWidths.count > 0 {
                    cell.width.isHidden = false
                    cell.width.isUserInteractionEnabled = true
                    cell.widthTextField.isHidden = true
                }else {
                    cell.width.isHidden = true
                    cell.width.isUserInteractionEnabled = false
                    cell.widthTextField.isHidden = false
                }
                cell.length.setTitle(self.viewModel.relatedProdLength.value, for: .normal)
                cell.width.setTitle(self.viewModel.relatedProdWidth.value, for: .normal)
                cell.lengthTextField.text = self.viewModel.relatedProdLength.value ?? ""
                cell.widthTextField.text = self.viewModel.relatedProdWidth.value ?? ""
            }
            
        })
        <<< RoundedButtonViewRow("Next6") {
            $0.tag = "Next6"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next".localized, for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = CustomProductState.dimensions.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(CustomProductState.gsm.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 7, title: "Enter the GSM value of fabric")
                  return view
                }))
                header.height = { ht }
                return header
              }()
            if self.viewModel.prodCategory.value?.prodCatDescription == "Fabric" {
                section.hidden = false
            }else {
                section.hidden = true
            }
        }
        <<< ImageViewRow() {
            $0.cell.height = { 120.0 }
            $0.cell.cellImage.image = UIImage(named: "GSM ")
            $0.hidden = true
        }.cellUpdate({ (cell, row) in
            if self.viewModel.prodCategory.value?.prodCatDescription == "Fabric" {
                cell.height = { 60.0 }
            }else {
                cell.height = { 0.0 }
            }
        })
        <<< RoundedTextFieldRow() {
            $0.tag = "GSMRow"
            $0.cell.titleLabel.text = "GSM".localized
            $0.cell.compulsoryIcon.isHidden = true
            $0.hidden = true
            self.viewModel.gsm.bidirectionalBind(to: $0.cell.valueTextField.reactive.text)
            $0.cell.valueTextField.text = self.viewModel.gsm.value
            self.viewModel.gsm.value = $0.cell.valueTextField.text
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.cellUpdate({ (cell, row) in
            self.viewModel.gsm.value = cell.valueTextField.text
            cell.valueTextField.maxLength = 10
            if self.viewModel.prodCategory.value?.prodCatDescription == "Fabric" {
                cell.height = { 80.0 }
            }else {
                cell.height = { 0.0 }
            }
        })
        <<< RoundedButtonViewRow("Next7") {
            $0.tag = "Next7"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().CEGreen()
            $0.cell.buttonView.backgroundColor = UIColor().CEGreen()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle("Next".localized, for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "pencil"), for: .normal)
            $0.cell.tag = CustomProductState.gsm.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
        +++ Section(){ section in
            section.tag = "\(CustomProductState.addDescription.rawValue)"
            let ht: CGFloat = 60.0
            section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                    let view = self.createSectionView(forStep: 8, title: "Description")
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
            self.viewModel.prodDescription.bidirectionalBind(to: $0.cell.textView.reactive.text)
            $0.cell.textView.text = self.viewModel.prodDescription.value ?? ""
            $0.value = self.viewModel.prodDescription.value ?? ""
            if fromEnquiry {
                $0.cell.isUserInteractionEnabled = false
            }
        }.cellUpdate({ (cell, row) in
            cell.textView.delegate = self
            self.viewModel.prodDescription.value = cell.textView.text
        })
        <<< RoundedButtonViewRow("Next8") {
            $0.tag = "Next8"
            $0.cell.titleLabel.isHidden = true
            $0.cell.compulsoryIcon.isHidden = true
            $0.cell.greyLineView.isHidden = true
            $0.cell.buttonView.borderColour = UIColor().menuSelectorBlue()
            $0.cell.buttonView.backgroundColor = UIColor().menuSelectorBlue()
            $0.cell.buttonView.setTitleColor(.white, for: .normal)
            $0.cell.buttonView.setTitle(" Save ", for: .normal)
            $0.cell.buttonView.setImage(UIImage.init(named: "save and upload"), for: .normal)
            $0.cell.buttonView.tintColor = .white
            $0.cell.tag = CustomProductState.addDescription.rawValue
            $0.cell.height = { 80.0 }
            $0.cell.delegate = self
            $0.hidden = true
        }
    }
    
    @objc func backSelected(_ sender: Any) {
        self.confirmAction("Warning", "Are you sure you don't want to save this new product?", confirmedCallback: { (action) in
            self.navigationController?.popViewController(animated: true)
        }) { (action) in
        }
    }
    
    func downloadProdImages() {
        product?.productImages .forEach { (image) in
            let tag = image.lable
            let prodId = product?.entityID
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                if !(viewModel.productImages.value?.contains(downloadedImage) ?? false) {
                    viewModel.productImages.value?.append(downloadedImage)
                }
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = CustomProductImageService.init(client: client, productObject: product!)
                    service.fetchCustomImage(withName: tag ?? "name.jpg").observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = image.lable ?? "name.jpg"
                            let prodId = self.product?.entityID
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId ?? 0)/\(tag)")
                            self.viewModel.productImages.value?.append(UIImage.init(data: attachment) ?? UIImage())
                        }
                    }.dispose(in: self.bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
            if image == product?.productImages.last {
                let row = self.form.rowBy(tag: "AddPhotoRow") as? CollectionViewRow
                row?.cell.collectionView.reloadData()
            }
        }
    }

    @objc func expandSectionSelected(sender: UIButton) {
        expandSection(tag: sender.tag)
    }
    
    @objc func expandSection(tag: Int) {
        if currentState?.rawValue != tag {
            if tag == 6 {
                if viewModel.prodCategory.value?.prodCatDescription == "Fabric" {
                    currentState = CustomProductState.init(rawValue: tag)
                }else {
                    currentState = CustomProductState.init(rawValue: tag+1)
                }
            }else {
                currentState = CustomProductState.init(rawValue: tag)
            }
            self.form.allSections .forEach { (section) in
                if section.tag == "\(currentState?.rawValue ?? 20)" {
                    section.allRows .forEach { (row) in
                        row.hidden = false
                        row.evaluateHidden()
                        if fromEnquiry && row.tag == "Next8" {
                            row.hidden = true
                            row.evaluateHidden()
                        }
                    }
                }else {
                    section.allRows .forEach { (row) in
                        row.hidden = true
                        row.evaluateHidden()
                    }
                }
                evaluateDot(section: section)
            }
        }else {
            if let section = self.form.sectionBy(tag: "\(tag)") {
                section.allRows .forEach { (row) in
                    row.hidden = true
                    row.evaluateHidden()
                }
                currentState = nil
                evaluateDot(section: section)
            }
        }
    }
    
    func evaluateDot(section: Section) {
        let headerView = section.header?.viewForSection(section, type: .header)
        let circle = headerView?.viewWithTag(333)
        let stepLbl = headerView?.viewWithTag(444) as! UILabel
        if section.tag == "\(CustomProductState.addPhotos.rawValue)" {
            //Photos
            circle?.backgroundColor = self.viewModel.productImages.value?.count ?? 0 > 0 ? UIColor().CEGreen() : .red
        }else if section.tag == "\(CustomProductState.addGeneralDetails.rawValue)" {
            //General info
            if viewModel.prodCategory.value != nil && viewModel.prodType.value != nil {
                circle?.backgroundColor = UIColor().CEGreen()
            }else {
                circle?.backgroundColor = .red
            }
        }else if section.tag == "\(CustomProductState.selectWeaveType.rawValue)" {
            //weave types
            circle?.backgroundColor = self.viewModel.prodWeaveType.value?.count ?? 0 > 0 ? UIColor().CEGreen() : .red
        }else if section.tag == "\(CustomProductState.selectWarpWeftYarn.rawValue)" {
            //Warp X Weft X Yarn
            if viewModel.warpYarn.value != nil && viewModel.warpDye.value != nil &&
                (viewModel.warpYarnCnt.value != nil || (viewModel.custWarpYarnCnt.value != nil && viewModel.custWarpYarnCnt.value?.trimmingCharacters(in: .whitespacesAndNewlines) != "")) &&
                viewModel.weftYarn.value != nil && viewModel.weftDye.value != nil &&
                (viewModel.weftYarnCnt.value != nil || (viewModel.custWeftYarnCnt.value != nil && viewModel.custWeftYarnCnt.value?.trimmingCharacters(in: .whitespacesAndNewlines) != "")) {
                circle?.backgroundColor = UIColor().CEGreen()
            }else {
                circle?.backgroundColor = .red
            }
        }else if section.tag == "\(CustomProductState.reedCount.rawValue)" {
            //reed count
            circle?.backgroundColor = viewModel.reedCount.value != nil ? UIColor().CEGreen() : .red
        }else if section.tag == "\(CustomProductState.dimensions.rawValue)" {
            //dimensions
            if viewModel.prodLength.value != nil && viewModel.prodWidth.value != nil &&
                viewModel.prodLength.value?.trimmingCharacters(in: .whitespacesAndNewlines) != "" &&
                viewModel.prodWidth.value?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                circle?.backgroundColor = UIColor().CEGreen()
            }else {
                circle?.backgroundColor = .red
            }
        }else if section.tag == "\(CustomProductState.gsm.rawValue)" {
            //gsm
            circle?.backgroundColor = (viewModel.gsm.value != nil &&
            viewModel.gsm.value?.trimmingCharacters(in: .whitespacesAndNewlines) != "") ? UIColor().CEGreen() : .red
        }else if section.tag == "\(CustomProductState.addDescription.rawValue)" {
            //prod description
            if viewModel.prodCategory.value?.prodCatDescription == "Fabric" {
                stepLbl.text = "Step 8:".localized
            }else {
                stepLbl.text = "Step 7:".localized
            }
            circle?.backgroundColor = (viewModel.prodDescription.value != nil &&
            viewModel.prodDescription.value?.trimmingCharacters(in: .whitespacesAndNewlines) != "") ? UIColor().CEGreen() : .red
        }
    }
    
    func createSectionView(forStep:Int, title:String) -> UIView {
        let ht: CGFloat = 60.0
        let width: CGFloat = self.view.frame.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: width, height: ht))
        let y = 5
        let lblHt = 40
        let dotView = UIView(frame: CGRect(x: 20, y: 15, width: 20, height: 20))
        dotView.backgroundColor = self.product != nil ? UIColor().CEGreen() : .red
        dotView.layer.cornerRadius = 10
        dotView.tag = 333
        view.addSubview(dotView)
        
        let stepLbl = UILabel.init(frame: CGRect(x: dotView.frame.origin.x + dotView.frame.size.width + 5, y: CGFloat(y), width: CGFloat(70), height: CGFloat(lblHt)))
        stepLbl.font = .systemFont(ofSize: 17, weight: .regular)
        stepLbl.textColor = .darkGray
        stepLbl.text = "Step \(forStep):".localized
        stepLbl.tag = 444
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
    
    @objc func saveClicked() {
        self.viewModel.saveProductSelected?()
    }
    
    @objc func deleteClicked() {
        self.confirmAction("Warning".localized, "Are you sure you want to delete this product?".localized, confirmedCallback: { (action) in
            self.viewModel.deleteProductSelected?()
        }) { (action) in
            
        }
    }
    
}

extension UploadCustomProductController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 500
        let typeCasteToStringFirst = textView.text as NSString?
        if let newRange = textView.selectedRange {
            let newString = typeCasteToStringFirst?.replacingCharacters(in: newRange, with: text)
            return newString?.count ?? 0 <= maxLength
        }
        return true
    }
}

extension UploadCustomProductController: ButtonActionProtocol, DimensionCellProtocol, LengthWidthCellProtocol, ToggleButtonProtocol {
    func toggleButtonSelected(tag: Int, forWashCare: Bool) {
        if forWashCare == false {
            //Weave Cell
            if let weave = Weave.getWeaveType(searchId: tag) {
                if self.viewModel.prodWeaveType.value?.contains(weave) ?? false {
                    if let index = self.viewModel.prodWeaveType.value?.firstIndex(of: weave) {
                        self.viewModel.prodWeaveType.value?.remove(at: index)
                    }
                }else {
                    self.viewModel.prodWeaveType.value?.append(weave)
                }
            }
        }
    }
    
    func lengthWidthSelected(tag: Int, withValue: String) {
        print("tag: \(tag)")
        switch tag {
        case 1001:
            print("prod len")
            self.viewModel.prodLength.value = withValue
        case 1002:
            print("prod width")
            self.viewModel.prodWidth.value = withValue
        case 2001:
            print("rel prod len")
            self.viewModel.relatedProdLength.value = withValue
        case 2002:
            print("rel prod width")
            self.viewModel.relatedProdWidth.value = withValue
        default:
            print("")
        }
    }
    
    func customButtonSelected(tag: Int) {
        expandSection(tag: tag+1)
        if tag == CustomProductState.addDescription.rawValue {
            self.viewModel.saveProductSelected?()
        }
    }

    func showOption(tag: Int, withValue: String) {
        print("option")
        switch tag {
        case 101:
            print("warp yarn")
            self.viewModel.warpYarn.value = searchYarnOptions(value: withValue)
            self.viewModel.warpYarnCnt.value = nil
        case 102:
            print("warp yarn")
            self.viewModel.warpYarnCnt.value = searchYarnCntOptions(inYarn: self.viewModel.warpYarn.value, value: withValue)
        case 103:
            print("warp yarn")
            self.viewModel.warpDye.value = searchDyeOptions(value: withValue)
        case 201:
            print("weft yarn")
            self.viewModel.weftYarn.value = searchYarnOptions(value: withValue)
            self.viewModel.weftYarnCnt.value = nil
        case 202:
            print("weft yarn")
            self.viewModel.weftYarnCnt.value = searchYarnCntOptions(inYarn: self.viewModel.weftYarn.value, value: withValue)
        case 203:
            print("weft yarn")
            self.viewModel.weftDye.value = searchDyeOptions(value: withValue)
        case 301:
            print("ex-weft yarn")
            self.viewModel.exWeftYarn.value = searchYarnOptions(value: withValue)
            self.viewModel.exWeftYarnCnt.value = nil
        case 302:
            print("ex-weft yarn")
            self.viewModel.exWeftYarnCnt.value = searchYarnCntOptions(inYarn: self.viewModel.exWeftYarn.value, value: withValue)
        case 303:
            print("ex-weft yarn")
            self.viewModel.exWeftDye.value = searchDyeOptions(value: withValue)
        default:
            print("")
        }
    }
    
    func searchYarnOptions(value: String) -> Yarn? {
        let selectedObj = self.allYarns?.filter({ (obj) -> Bool in
            obj.yarnDesc == value
            }).first
        return selectedObj ?? nil
    }
    
    func searchYarnCntOptions(inYarn:Yarn?, value: String) -> YarnCount? {
        let selectedObj = inYarn?.yarnType.first?.yarnCounts.filter({ (obj) -> Bool in
            obj.count == value
            }).first
        return selectedObj ?? nil
    }
    
    func searchDyeOptions(value: String) -> Dye? {
        let selectedObj = self.allDye?.filter({ (obj) -> Bool in
            obj.dyeDesc == value
            }).first
        return selectedObj ?? nil
    }
}

extension UploadCustomProductController: UICollectionViewDelegate, UICollectionViewDataSource, AddImageProtocol {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if currentState == CustomProductState.selectWarpWeftYarn {
            return 3
        }
        var cnt: Int?
        if let _ = product {
            cnt = product?.productImages.count
        }else {
            cnt = viewModel.productImages.value?.count
        }
        if let count = cnt {
            if count == 3 {
                return 3
            }else {
                if fromEnquiry {
                    return count
                }
                return count+1
            }
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if currentState == CustomProductState.selectWarpWeftYarn {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DimensionsCardCell",
            for: indexPath) as! DimensionsCardCell
            cell.dimensionDelegate = self
            cell.layer.borderWidth = 0.0
            cell.layer.shadowColor = UIColor.lightGray.cgColor
            cell.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell.layer.shadowRadius = 5.0
            cell.layer.shadowOpacity = 1
            cell.layer.masksToBounds = false
            cell.option1 = allYarns?.compactMap({$0.yarnDesc})
            cell.option2 = self.viewModel.warpYarn.value?.yarnType.first?.yarnCounts.compactMap({$0.count})
            cell.option3 = allDye?.compactMap({$0.dyeDesc})
            switch indexPath.row {
            case 0:
                print("Add Warp")
                cell.cardImg.image = UIImage.init(named: "warp")
                cell.cardTitle.text = "Warp".localized
                cell.optionalLbl.isHidden = true
                cell.buttonOne.tag = 101
                cell.buttonTwo.tag = 102
                cell.buttonThree.tag = 103
                self.viewModel.custWarpYarnCnt.bidirectionalBind(to: cell.yarnCountTextField.reactive.text)
                cell.yarnCountTextField.text = self.viewModel.custWarpYarnCnt.value ?? ""
                self.viewModel.custWarpYarnCnt.value = cell.yarnCountTextField.text
                if self.viewModel.warpYarn.value?.yarnType.first?.manual == true {
                    cell.yarnCountTextField.isHidden = false
                    cell.buttonTwo.isHidden = true
                    cell.buttonTwo.isUserInteractionEnabled = false
                }else {
                    cell.yarnCountTextField.isHidden = true
                    cell.buttonTwo.isHidden = false
                    cell.buttonTwo.isUserInteractionEnabled = true
                }
                if self.product != nil {
                    cell.buttonOne.setTitle(self.viewModel.warpYarn.value?.yarnDesc, for: .normal)
                    cell.buttonTwo.setTitle(self.viewModel.warpYarnCnt.value?.count, for: .normal)
                    cell.buttonThree.setTitle(self.viewModel.warpDye.value?.dyeDesc, for: .normal)
                }
            case 1:
                print("Add Weft")
                cell.cardImg.image = UIImage.init(named: "weft")
                cell.cardTitle.text = "Weft".localized
                cell.optionalLbl.isHidden = true
                cell.buttonOne.tag = 201
                cell.buttonTwo.tag = 202
                cell.buttonThree.tag = 203
                self.viewModel.custWeftYarnCnt.bidirectionalBind(to: cell.yarnCountTextField.reactive.text)
                cell.yarnCountTextField.text = self.viewModel.custWeftYarnCnt.value ?? ""
                self.viewModel.custWeftYarnCnt.value = cell.yarnCountTextField.text
                if self.viewModel.weftYarn.value?.yarnType.first?.manual == true {
                    cell.yarnCountTextField.isHidden = false
                    cell.buttonTwo.isHidden = true
                    cell.buttonTwo.isUserInteractionEnabled = false
                }else {
                    cell.yarnCountTextField.isHidden = true
                    cell.buttonTwo.isHidden = false
                    cell.buttonTwo.isUserInteractionEnabled = true
                }
                if self.product != nil {
                    cell.buttonOne.setTitle(self.viewModel.weftYarn.value?.yarnDesc, for: .normal)
                    cell.buttonTwo.setTitle(self.viewModel.weftYarnCnt.value?.count, for: .normal)
                    cell.buttonThree.setTitle(self.viewModel.weftDye.value?.dyeDesc, for: .normal)
                }
            case 2:
                print("Add Extra Weft")
                cell.cardImg.image = UIImage.init(named: "extra weft")
                cell.cardTitle.text = "Extra Weft".localized
                cell.optionalLbl.isHidden = false
                cell.buttonOne.tag = 301
                cell.buttonTwo.tag = 302
                cell.buttonThree.tag = 303
                self.viewModel.custExWeftYarnCnt.bidirectionalBind(to: cell.yarnCountTextField.reactive.text)
                cell.yarnCountTextField.text = self.viewModel.custExWeftYarnCnt.value ?? ""
                self.viewModel.custExWeftYarnCnt.value = cell.yarnCountTextField.text
                if self.viewModel.exWeftYarn.value?.yarnType.first?.manual == true {
                    cell.yarnCountTextField.isHidden = false
                    cell.buttonTwo.isHidden = true
                    cell.buttonTwo.isUserInteractionEnabled = false
                }else {
                    cell.yarnCountTextField.isHidden = true
                    cell.buttonTwo.isHidden = false
                    cell.buttonTwo.isUserInteractionEnabled = true
                }
                if self.product != nil {
                    cell.buttonOne.setTitle(self.viewModel.exWeftYarn.value?.yarnDesc, for: .normal)
                    cell.buttonTwo.setTitle(self.viewModel.exWeftYarnCnt.value?.count, for: .normal)
                    cell.buttonThree.setTitle(self.viewModel.exWeftDye.value?.dyeDesc, for: .normal)
                }
            default:
                print("")
            }
            if fromEnquiry {
                cell.isUserInteractionEnabled = false
            }
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSelectorCell",
                                                      for: indexPath) as! ImageSelectorCell
        var showDefaultCell = false
        var cnt: Int?
        if let _ = product {
            cnt = product?.productImages.count
        }else {
            cnt = viewModel.productImages.value?.count
        }
        if let count = cnt, cnt ?? 0 > 0 {
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
            cell.addImageButton.setImage(UIImage.init(named: "loading-indicator"), for: .normal)
            if viewModel.productImages.value?.count ?? 0 > indexPath.row {
                if let image = viewModel.productImages.value?[indexPath.row] {
                    cell.addImageButton.setImage(image, for: .normal)
                }
            }
            else {
                let tag = product?.productImages[indexPath.row].lable
                let prodId = product?.entityID
                if let downloadedImage = try? Disk.retrieve("\(prodId ?? 0)/\(tag ?? "name.png")", from: .caches, as: UIImage.self) {
                    if !(viewModel.productImages.value?.contains(downloadedImage) ?? false) {
                        viewModel.productImages.value?.append(downloadedImage)
                    }
                    if let image = viewModel.productImages.value?[indexPath.row] {
                        cell.addImageButton.setImage(image, for: .normal)
                    }
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = CustomProductImageService.init(client: client, productObject: product!)
                        service.fetchCustomImage(withName: tag ?? "name.jpg").observeNext { (attachment) in
                            DispatchQueue.main.async {
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId ?? 0)/\(tag ?? "name.png")")
                                self.viewModel.productImages.value?.append(UIImage.init(data: attachment) ?? UIImage())
                                cell.addImageButton.setImage(UIImage.init(data: attachment) ?? UIImage.init(named: "loading-indicator"), for: .normal)
                            }
                        }.dispose(in: self.bag)
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            cell.addImageButton.isUserInteractionEnabled = false
            cell.deleteImageButton.isHidden = false
            cell.deleteImageButton.isUserInteractionEnabled = true
            cell.deleteImageButton.tag = indexPath.row
            cell.editImageButton.isHidden = false
            cell.editImageButton.isUserInteractionEnabled = true
            cell.editImageButton.tag = indexPath.row
            cell.lineView.isHidden = false
        }
        cell.delegate = self
        if fromEnquiry {
            cell.isUserInteractionEnabled = false
            cell.deleteImageButton.isHidden = true
            cell.editImageButton.isHidden = true
            cell.lineView.isHidden = true
        }
        return cell
    }
    
    @objc func addImageSelected(atIndex: Int) {
        self.showImagePickerAlert()
    }
    
    func deleteImageSelected(atIndex: Int) {
        self.viewModel.productImages.value?.remove(at: atIndex)
        reloadAddPhotoRow()
    }
    
    func editImageSelected(atIndex: Int) {
        
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "AddPhotoRow") as? CollectionViewRow
        row?.reload()
        row?.cell.collectionView.reloadData()
    }
}

extension UploadCustomProductController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
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

extension UploadCustomProductController: OfflineRequestManagerDelegate {
    func offlineRequest(withDictionary dictionary: [String : Any]) -> OfflineRequest? {
        return OfflineProductRequest(dictionary: dictionary)
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, shouldAttemptRequest request: OfflineRequest) -> Bool {
        return true
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, didUpdateConnectionStatus connected: Bool) {
        
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, didFinishRequest request: OfflineRequest) {
        
    }
    
    func offlineRequestManager(_ manager: OfflineRequestManager, requestDidFail request: OfflineRequest, withError error: Error) {
        
    }
}

