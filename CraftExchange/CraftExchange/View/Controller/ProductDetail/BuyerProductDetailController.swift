//
//  BuyerProductDetailController.swift
//  CraftExchange
//
//  Created by Preety Singh on 18/08/20.
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

class BuyerProductDetailController: FormViewController {

    var product: Product?
    var productImages: [UIImage]? = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none

        let weaveTypeSection = Section() {
            $0.hidden = "$weaveTypes == false"
        }

        let weaveTypeView = LabelRow("weaveTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Weave types used"
        }
        
        let washSection = Section() {
            $0.hidden = "$washTypes == false"
        }

        let washView = LabelRow("washTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Wash Care Instructions"
        }

        form
        +++ Section()
            <<< ImageViewRow() {
                $0.cell.height = { 130.0 }
                $0.cell.title.text = product?.productTag ?? ""
                $0.cell.productCodeValue.text = product?.code ?? ""
                $0.cell.title.isHidden = false
                $0.cell.productCodeValue.isHidden = false
                $0.cell.productCodeLbl.isHidden = false
            }
            <<< CollectionViewRow() {
                $0.tag = "PhotoRow"
                $0.cell.collectionView.register(UINib(nibName: "ImageSelectorCell", bundle: nil), forCellWithReuseIdentifier: "ImageSelectorCell")
                $0.cell.collectionDelegate = self
                $0.cell.height = { 280.0 }
            }
            <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = "Product Description"
            }
            <<< ProdDetailDescriptionRow() {
                let ht = UIView().heightForView(text: product?.productSpec ?? product?.productDesc ?? "", width: self.view.frame.size.width - 200)
                $0.cell.height = { ht < 80 ? 80 : ht+10 }
                print("ht\(ht)")
                $0.cell.productDescLbl.text = product?.productSpec ?? product?.productDesc ?? ""
                $0.cell.productDescLbl.textColor = .darkGray
                $0.cell.productDescLbl.numberOfLines = 10
            }
            <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = "Product Details".localized
            }
            <<< ProductDetailInfoRow() {
                $0.cell.height = { 100.0 }
                $0.cell.productCatLbl.text = ProductCategory.getProductCat(catId: product?.productCategoryId ?? 0)?.prodCatDescription
                $0.cell.productTypeLbl.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc
                if product?.productStatusId != 2 {
                    $0.cell.productAvailabilityLbl.text = "In Stock"
                    $0.cell.productAvailabilityLbl.textColor = UIColor().CEGreen()
                    $0.cell.madeToOrderLbl.isHidden = true
                }
            }
            <<< weaveTypeView
            +++ weaveTypeSection
            +++ Section()
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
            }
            <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = "Weaves used".localized
            }
            <<< ProdDetailYarnRow {
                $0.cell.height = { 100.0 }
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.titleLbl.text = " Yarn"
                $0.cell.valueLbl1.text = Yarn.getYarn(searchId: product?.warpYarnId ?? 0)?.yarnDesc ?? "NA"
                $0.cell.valueLbl2.text = Yarn.getYarn(searchId: product?.weftYarnId ?? 0)?.yarnDesc ?? "NA"
                $0.cell.valueLbl3.text = Yarn.getYarn(searchId: product?.extraWeftYarnId ?? 0)?.yarnDesc ?? "NA"
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.titleLbl.text = " Yarn \n Count"
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.valueLbl1.text = product?.warpYarnCount ?? "NA"
                $0.cell.valueLbl2.text = product?.weftYarnCount ?? "NA"
                $0.cell.valueLbl3.text = product?.extraWeftYarnCount ?? "NA"
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.titleLbl.text = " Dye"
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.valueLbl1.text = Dye.getDyeType(searchId: product?.warpDyeId ?? 0)?.dyeDesc ?? "NA"
                $0.cell.valueLbl2.text = Dye.getDyeType(searchId: product?.weftDyeId ?? 0)?.dyeDesc ?? "NA"
                $0.cell.valueLbl3.text = Dye.getDyeType(searchId: product?.extraWeftDyeId ?? 0)?.dyeDesc ?? "NA"
            }
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "reed count")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Reed count"
                $0.cell.titleLbl.textColor = .black
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ReedCount.getReedCount(searchId: product?.reedCountId ?? 0)?.count ?? "NA"
                $0.cell.valueLbl3.text = ""
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Icon weight")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Weight"
                $0.cell.titleLbl.textColor = .black
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = product?.weight ?? "NA"
                $0.cell.valueLbl3.text = ""
                if product?.relatedProducts.count ?? 0 > 0 {
                    $0.hidden = true
                }else {
                    $0.hidden = false
                }
            }
            <<< ProdDetailsRelatedRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Icon weight")
                $0.cell.titleLbl.text = "Weight"
                $0.cell.prodLbl.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.prodValueLbl.text = "\(product?.weight ?? "NA")"
                $0.cell.relatedProdLbl.text = ProductType.getProductType(searchId: product?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                $0.cell.relatedProdValueLbl.text = "\(product?.relatedProducts.first?.weight ?? "NA")"
                if product?.relatedProducts.count ?? 0 > 0 {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "dimension")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Dimensions\nL X W"
                $0.cell.titleLbl.textColor = .black
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.titleLbl.font = .systemFont(ofSize: 14)
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.valueLbl3.text = "\(product?.length ?? "NA") X \(product?.width ?? "NA")"
                if product?.relatedProducts.count ?? 0 > 0 {
                    $0.hidden = true
                }else {
                    $0.hidden = false
                }
            }
            <<< ProdDetailsRelatedRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "dimension")
                $0.cell.titleLbl.text = "Dimensions\nL X W"
                $0.cell.prodLbl.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.prodValueLbl.text = "\(product?.length ?? "NA") X \(product?.width ?? "NA")"
                $0.cell.relatedProdLbl.text = ProductType.getProductType(searchId: product?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                $0.cell.relatedProdValueLbl.text = "\(product?.relatedProducts.first?.length ?? "NA") X \(product?.relatedProducts.first?.width ?? "NA")"
                if product?.relatedProducts.count ?? 0 > 0 {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
                let str = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                if str == "Fabric" {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "GSM ")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "GSM\n(Gram per square meter)"
                $0.cell.titleLbl.textColor = .black
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.titleLbl.font = .systemFont(ofSize: 13)
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.valueLbl3.text = product?.gsm ?? "NA"
                if $0.cell.valueLbl2.text == "Fabric" {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
            }
            <<< washView
            +++ washSection
        
        var strArr:[String] = []
        product?.weaves .forEach({ (weave) in
            strArr.append("\(Weave.getWeaveType(searchId: weave.weaveId)?.weaveDesc ?? "")")
        })
        let setWeave = Set(strArr)
        setWeave.forEach({ (weave) in
            weaveTypeSection <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = weave
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = .darkGray
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .light)
            })
        })
        
        var washArr:[String] = []
        product?.productCares .forEach({ (obj) in
            washArr.append("\(ProductCare.getCareType(searchId: obj.productCareId)?.productCareDesc ?? "")")
        })
        let setCare = Set(washArr)
        setCare.forEach({ (obj) in
            washSection <<< LabelRow() {
                $0.cell.height = { 60.0 }
                $0.title = obj
            }.cellUpdate({ (cell, row) in
                cell.imageView?.image = UIImage.init(named: obj)
                cell.textLabel?.textColor = UIColor().washCareBlue()
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .light)
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        downloadProdImages()
    }
    
}

extension BuyerProductDetailController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.productImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSelectorCell",
                                                      for: indexPath) as! ImageSelectorCell
        cell.addImageButton.setImage(self.productImages?[indexPath.row], for: .normal)
        cell.addImageButton.isUserInteractionEnabled = false
        cell.deleteImageButton.isHidden = true
        cell.deleteImageButton.isUserInteractionEnabled = false
        cell.deleteImageButton.tag = indexPath.row
        cell.editImageButton.isHidden = true
        cell.editImageButton.isUserInteractionEnabled = false
        cell.lineView.isHidden = true
        cell.contentView.backgroundColor = .white
        return cell
    }
    
    @objc func addImageSelected() {
        self.showImagePickerAlert()
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "AddPhotoRow") as? CollectionViewRow
        row?.reload()
        row?.cell.collectionView.reloadData()
    }
    
    func downloadProdImages() {
        product?.productImages .forEach { (image) in
            let tag = image.lable
            let prodId = product?.entityID
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.productImages?.append(downloadedImage)
                if image == product?.productImages.last {
                    let row = self.form.rowBy(tag: "PhotoRow") as? CollectionViewRow
                    row?.cell.collectionView.reloadData()
                }
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = ProductImageService.init(client: client, productObject: product!, withName: image.lable ?? "name.jpg")
                    service.fetch(withName: tag ?? "name.jpg").observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = image.lable ?? "name.jpg"
                            let prodId = self.product?.entityID
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                            self.productImages?.append(UIImage.init(data: attachment) ?? UIImage())
                            if image == self.product?.productImages.last {
                                let row = self.form.rowBy(tag: "PhotoRow") as? CollectionViewRow
                                row?.cell.collectionView.reloadData()
                            }
                        }
                    }.dispose(in: self.bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}
