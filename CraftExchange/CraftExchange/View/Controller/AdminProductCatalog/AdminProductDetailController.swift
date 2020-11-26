//
//  AdminProductDetailController.swift
//  CraftExchange
//
//  Created by Kiran Songire on 27/10/20.
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

class AdminProductDetailController: FormViewController {
    
    var product: Product?
    var customProduct: CustomProduct?
    var productImages: [UIImage]? = []
    var showMoreProduct: Int = -1
    var addProdDetailToWishlist: ((_ prodId: Int) -> ())?
    var deleteProdDetailToWishlist: ((_ prodId: Int) -> ())?
    var viewWillAppear: (() -> ())?
    var suggestedProdArray: Results<Product>?
    var checkEnquiry: ((_ prodId: Int) -> ())?
    var generateNewEnquiry: ((_ prodId: Int) -> ())?
    var showNewEnquiry: ((_ enquiryId: Int) -> ())?
    var isCustom = false
    var isRedirect = false
    var enquiryCode: String?
    var enquiryDate: String?
    var buyerBrand: String?
    var enquiryId: Int?
    var isEdit = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.tableView.backgroundColor = .black
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        if isRedirect {
            let rightButtonItem = UIBarButtonItem.init(title: "Select Artisan", style: .plain, target: self, action: #selector(saveClicked))
            self.navigationItem.rightBarButtonItem = rightButtonItem
        }
        
        let weaveTypeSection = Section() {
            $0.tag = "weave section"
            $0.hidden = "$weaveTypes == false"
        }
        
        let weaveTypeView = LabelRow("weaveTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Weave types used"
            $0.cell.contentView.backgroundColor = .black
        }.cellUpdate { (cell, row) in
            cell.textLabel?.textColor = .white
        }
        
        let washSection = Section() {
            $0.tag = "wash section"
            $0.hidden = "$washTypes == false"
        }
        
        let washView = LabelRow("washTypes") {
            $0.cell.height = { 30.0 }
            $0.title = "Wash Care Instructions"
            $0.cell.contentView.backgroundColor = .black
            if isCustom {
                $0.hidden = true
            }
        }.cellUpdate { (cell, row) in
            cell.textLabel?.textColor = .white
        }
        
        viewWillAppear?()
        
        form
            +++ Section()
            <<< ImageViewRow() {
                $0.tag = "ProductNameRow"
                $0.cell.height = { 130.0 }
                $0.cell.title.text = product?.productTag ?? self.enquiryCode ?? ""
                if isCustom {
                    $0.cell.productCodeLbl.text = self.enquiryDate
                }
                $0.cell.productCodeValue.text = product?.code ?? self.buyerBrand ?? ""
                $0.cell.title.isHidden = false
                $0.cell.productCodeValue.isHidden = false
                $0.cell.productCodeLbl.isHidden = false
                $0.cell.editButton.tag = 101
                $0.cell.tag = 101
                $0.cell.editButton.isHidden = true
                if product?.madeWithAnthran == 1 && isEdit {
                    $0.cell.editButton.isHidden = false
                }
                $0.cell.delegate2 = self
                
            }.cellUpdate({ (cell, row) in
                cell.title.text = self.product?.productTag ?? self.enquiryCode ?? ""
                if self.isCustom {
                    cell.productCodeLbl.text = self.enquiryDate
                }
                cell.productCodeValue.text = self.product?.code ?? self.buyerBrand ?? ""
                cell.editButton.isHidden = true
                if self.product?.madeWithAnthran == 1 && self.isEdit{
                    cell.editButton.isHidden = false
                }
            })
            <<< CollectionViewRow() {
                $0.tag = "PhotoRow"
                $0.cell.collectionView.register(UINib(nibName: "ImageSelectorCell", bundle: nil), forCellWithReuseIdentifier: "ImageSelectorCell")
                $0.cell.collectionDelegate = self
                $0.cell.height = { 280.0 }
                $0.cell.contentView.backgroundColor = .black
            }
            <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = "Product Description"
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = .white
            }
            <<< ProdDetailDescriptionRow() {
                let ht = UIView().heightForView(text: product?.productSpec ?? product?.productDesc ?? customProduct?.productSpec ?? "", width: self.view.frame.size.width - 200)
                $0.cell.height = { ht < 80 ? 80 : ht+10 }
                print("ht\(ht)")
                $0.cell.productDescLbl.text = product?.productSpec ?? product?.productDesc ?? customProduct?.productSpec ?? ""
                $0.cell.productDescLbl.textColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
                $0.cell.productDescLbl.numberOfLines = 10
            }.cellUpdate({ (cell, row) in
                cell.productDescLbl.text = self.product?.productSpec ?? self.product?.productDesc ?? self.customProduct?.productSpec ?? ""
            })
            <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = "Product Details".localized
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = .white
            }
            <<< ProductDetailInfoRow() {
                $0.cell.height = { 100.0 }
            }.cellUpdate({ (cell, row) in

                cell.productCatLbl.text = ProductCategory.getProductCat(catId: self.product?.productCategoryId ?? self.customProduct?.productCategoryId ?? 0)?.prodCatDescription
                cell.productTypeLbl.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc
                if !self.isCustom {
                    cell.productTypeLbl.text = ClusterDetails.getCluster(clusterId: self.product?.clusterId ?? 0)?.clusterDescription ?? "-"
                }
                
                if self.product?.productStatusId == 2 {
                    cell.productAvailabilityLbl.text = "In Stock"
                    cell.productAvailabilityLbl.textColor = #colorLiteral(red: 0.6266219616, green: 0.8538652062, blue: 0.7403210998, alpha: 1)
                    cell.madeToOrderLbl.isHidden = true
                }
//                else if self.customProduct?.entityID != 0 {
//                    cell.productAvailabilityLbl.text = "Custom Product"
//                }
                if self.isCustom {
                    cell.prodTypeTitle.text = "Product Type:"
                    cell.prodAvailableTitle.isHidden = true
                    cell.productAvailabilityLbl.isHidden = true
                    cell.madeToOrderLbl.isHidden = true
                }
                
            })
//            <<< LabelRow {
//                $0.cell.height = { 1.0 }
//                $0.cell.backgroundColor = .lightGray
//            }
//            <<< LabelRow() {
//                $0.cell.height = { 30.0 }
//                $0.title = "Artisan brand".localized
//                $0.cell.contentView.backgroundColor = .black
//            }.cellUpdate { (cell, row) in
//                cell.textLabel?.textColor = .white
//            }
//            <<< ProdDetailYarnValueRow {
//                $0.tag = "ArtisanBrandRow"
//                $0.cell.height = { 80.0 }
//                $0.cell.titleLbl.isHidden = true
//                $0.cell.rowImage.isHidden = false
//                $0.cell.rowImageWidthConstraint.constant = 60
//                $0.cell.valueLbl1.text = "      "
//                $0.cell.valueLbl2.text = "      "
//                $0.cell.valueLbl3.text = "      "
//            }
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
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
                $0.cell.contentView.backgroundColor = .black
            }.cellUpdate { (cell, row) in
                cell.textLabel?.textColor = .white
            }
            <<< ProdDetailYarnRow {
                $0.cell.height = { 100.0 }
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                
            }.cellUpdate({ (cell, row) in
                cell.titleLbl.text = " Yarn"
                cell.valueLbl1.text = Yarn.getYarn(searchId: self.product?.warpYarnId ?? self.customProduct?.warpYarnId ?? 0)?.yarnDesc ?? "-"
                cell.valueLbl2.text = Yarn.getYarn(searchId: self.product?.weftYarnId ?? self.customProduct?.weftYarnId ?? 0)?.yarnDesc ?? "-"
                cell.valueLbl3.text = Yarn.getYarn(searchId: self.product?.extraWeftYarnId ?? self.customProduct?.weftYarnId ?? 0)?.yarnDesc ?? "-"
            })
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.titleLbl.text = " Yarn \n Count"
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                
            }.cellUpdate({ (cell, row) in
                cell.valueLbl1.text = self.product?.warpYarnCount ?? self.customProduct?.warpYarnCount ?? "-"
                cell.valueLbl2.text = self.product?.weftYarnCount ?? self.customProduct?.weftYarnCount ?? "-"
                cell.valueLbl3.text = self.product?.extraWeftYarnCount ?? self.customProduct?.extraWeftYarnCount ?? "-"
            })
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.titleLbl.text = " Dye"
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                
            }.cellUpdate({ (cell, row) in
                cell.valueLbl1.text = Dye.getDyeType(searchId: self.product?.warpDyeId ?? self.customProduct?.warpDyeId ?? 0)?.dyeDesc ?? "-"
                cell.valueLbl2.text = Dye.getDyeType(searchId: self.product?.weftDyeId ?? self.customProduct?.weftDyeId ?? 0)?.dyeDesc ?? "-"
                cell.valueLbl3.text = Dye.getDyeType(searchId: self.product?.extraWeftDyeId ?? self.customProduct?.extraWeftDyeId ?? 0)?.dyeDesc ?? "-"
            })
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Reed Count-1")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Reed count"
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.valueLbl1.text = ""
                
            }.cellUpdate({ (cell, row) in
                cell.valueLbl2.text = ReedCount.getReedCount(searchId: self.product?.reedCountId ?? self.customProduct?.reedCountId ?? 0)?.count ?? "-"
                cell.valueLbl3.text = ""
            })
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Icon weight white")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Weight"
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = self.product?.weight ?? "-"
                $0.cell.valueLbl3.text = ""
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0  {
                    $0.hidden = true
                }else {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                cell.valueLbl2.text = self.product?.weight ?? "-"
                cell.valueLbl3.text = ""
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0 {
                    cell.row.hidden = true
                }else {
                    cell.row.hidden = false
                }
            })
            <<< ProdDetailsRelatedRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Icon weight white")
                $0.cell.titleLbl.text = "Weight"
                $0.cell.prodLbl.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.prodValueLbl.text = "\(self.product?.weight ?? "-")"
                $0.cell.relatedProdLbl.text = ProductType.getProductType(searchId: self.product?.relatedProducts.first?.entityID ?? self.customProduct?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                $0.cell.relatedProdValueLbl.text = "\(self.product?.relatedProducts.first?.weight ?? "-")"
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0  {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
                
            }.cellUpdate({ (cell, row) in
                cell.prodLbl.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                cell.prodValueLbl.text = "\(self.product?.weight ?? "-")"
                cell.relatedProdLbl.text = ProductType.getProductType(searchId: self.product?.relatedProducts.first?.entityID ?? self.customProduct?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                cell.relatedProdValueLbl.text = "\(self.product?.relatedProducts.first?.weight ?? "-")"
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0  {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "rect dimns")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Dimensions\nL X W"
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.titleLbl.font = .systemFont(ofSize: 14)
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ProductType.getProductType(searchId: self.product?.productTypeId ??  self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.valueLbl3.text = "\(self.product?.length ?? self.customProduct?.length ?? "-") X \(self.product?.width ?? self.customProduct?.width ?? "-")"
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0 {
                    $0.hidden = true
                }else {
                    $0.hidden = false
                }
            }.cellUpdate({ (cell, row) in
                cell.valueLbl1.text = ""
                cell.valueLbl2.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? 0)?.productDesc ?? ""
                cell.valueLbl3.text = "\(self.product?.length ?? self.customProduct?.length ?? "-") X \(self.product?.width ?? self.customProduct?.width ?? "-")"
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0 {
                    cell.row.hidden = true
                }else {
                    cell.row.hidden = false
                }
            })
            <<< ProdDetailsRelatedRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Dimension white")
                $0.cell.titleLbl.text = "Dimensions\nL X W"
                $0.cell.prodLbl.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.prodValueLbl.text = "\(self.product?.length ?? self.customProduct?.length ?? "-") X \(self.product?.width ?? self.customProduct?.width ?? "-")"
                $0.cell.relatedProdLbl.text = ProductType.getProductType(searchId: self.product?.relatedProducts.first?.entityID ??  self.customProduct?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                $0.cell.relatedProdValueLbl.text = "\(self.product?.relatedProducts.first?.length ?? self.customProduct?.relatedProducts.first?.length ?? "-") X \(self.product?.relatedProducts.first?.width ?? self.customProduct?.relatedProducts.first?.width ?? "-")"
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0 {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }.cellUpdate({ (cell, row) in
                cell.titleLbl.text = "Dimensions\nL X W"
                cell.prodLbl.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                cell.prodValueLbl.text = "\(self.product?.length ?? self.customProduct?.length ?? "-") X \(self.product?.width ?? self.customProduct?.width ?? "-")"
                cell.relatedProdLbl.text = ProductType.getProductType(searchId: self.product?.relatedProducts.first?.entityID ??  self.customProduct?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                cell.relatedProdValueLbl.text = "\(self.product?.relatedProducts.first?.length ?? self.customProduct?.relatedProducts.first?.length ?? "-") X \(self.product?.relatedProducts.first?.width ?? self.customProduct?.relatedProducts.first?.width ?? "-")"
                if self.product?.relatedProducts.count ?? self.customProduct?.relatedProducts.count ?? 0 > 0 {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
                let str = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                if str == "Fabric" {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }.cellUpdate({ (cell, row) in
                let str = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                if str == "Fabric" {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "GSM white")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "GSM\n(Gram per square meter)"
                $0.cell.titleLbl.textColor = .black
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.titleLbl.font = .systemFont(ofSize: 13)
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.valueLbl3.text = self.product?.gsm ?? self.customProduct?.gsm ?? "-"
                if $0.cell.valueLbl2.text == "Fabric" {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }.cellUpdate({ (cell, row) in
                cell.valueLbl1.text = ""
                cell.valueLbl2.text = ProductType.getProductType(searchId: self.product?.productTypeId ?? self.customProduct?.productTypeId ?? 0)?.productDesc ?? ""
                cell.valueLbl3.text = self.product?.gsm ?? self.customProduct?.gsm ?? "-"
                if cell.valueLbl2.text == "Fabric" {
                    cell.row.hidden = false
                }else {
                    cell.row.hidden = true
                }
            })
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
                if isCustom {
                    $0.hidden = true
                }
            }
            <<< washView
            +++ washSection
            +++ Section()
        
        var strArr:[String] = []

        product?.weaves .forEach({ (weave) in
            strArr.append("\(Weave.getWeaveType(searchId: weave.weaveId)?.weaveDesc ?? "")")
        })
        customProduct?.weaves .forEach({ (weave) in
            strArr.append("\(Weave.getWeaveType(searchId: weave.weaveId)?.weaveDesc ?? "")")
        })
        let setWeave = Set(strArr)
        setWeave.forEach({ (weave) in
            weaveTypeSection <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = weave
                $0.cell.contentView.backgroundColor = .black
                // $0.cell.textLabel?.textColor = .white
            }.cellUpdate({ (cell, row) in
                cell.row.title = weave
                cell.textLabel?.textColor = #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1)
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
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
                $0.cell.contentView.backgroundColor = .black
                //  $0.cell.textLabel?.textColor = .white
            }.cellUpdate({ (cell, row) in
                cell.row.title = obj
                cell.imageView?.image = UIImage.init(named: obj)
                cell.textLabel?.textColor = UIColor().washCareBlue()
                cell.textLabel?.font = .systemFont(ofSize: 15, weight: .regular)
            })
        })
    }
    
    @objc func saveClicked() {
         print("redirect clicked")
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = AdminRedirectEnquiryService(client: client).createRedirectArtisanScene(enquiryId: self.enquiryId ?? 0, enquiryCode: self.enquiryCode ?? "", enquiryDate: self.enquiryDate ?? "", productCategory: ProductCategory.getProductCat(catId: self.customProduct?.productCategoryId ?? 0)?.prodCatDescription, isAll: true)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
        }catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if productImages?.count ?? 0 == 0 {
            downloadProdImages()
        }
      //  downloadArtisanBrandLogo()
        if let prodObj = product {
            suggestedProdArray = Product.getSuggestedProduct(forProdId: prodObj.entityID, catId: prodObj.productCategoryId, clusterID: prodObj.clusterId)
            let row = self.form.rowBy(tag: "SuggestionRow") as? CollectionViewRow
            row?.reload()
            row?.cell.collectionView.reloadData()
        }
    }
    
}

extension AdminProductDetailController:  ProdDetailEditProtocol {
    
    func editProductSelected(tag: Int) {
        switch tag {
        case 101:
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = UploadProductService(client: client).createScene(productObject: self.product)
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        default:
            print("do nothing")
        }
    }
    
}

extension AdminProductDetailController: UICollectionViewDelegate, UICollectionViewDataSource, AddImageProtocol {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2002 {
            return ((suggestedProdArray?.count ?? 0) > 5) ? 5 : suggestedProdArray?.count ?? 0
        }
        return self.productImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageSelectorCell",
                                                      for: indexPath) as! ImageSelectorCell
        cell.addImageButton.tag = 500+indexPath.row
        cell.addImageButton.isUserInteractionEnabled = true
        cell.delegate = self
        if collectionView.tag == 2002 {
            cell.addImageButton.tag = indexPath.row
            if let productObj = suggestedProdArray?[indexPath.row] {
                if let tag = productObj.productImages.first?.lable {
                    let prodId = productObj.entityID
                    if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        cell.addImageButton.setImage(downloadedImage, for: .normal)
                    }else {
                        do {
                            let client = try SafeClient(wrapping: CraftExchangeImageClient())
                            let service = ProductImageService.init(client: client, productObject: productObj)
                            service.fetch().observeNext { (attachment) in
                                DispatchQueue.main.async {
                                    let tag = productObj.productImages.first?.lable ?? "name.jpg"
                                    let prodId = productObj.entityID
                                    _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    cell.addImageButton.setImage(UIImage.init(data: attachment), for: .normal)
                                }
                            }.dispose(in: self.bag)
                        }catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }else {
            cell.addImageButton.setImage(self.productImages?[indexPath.row], for: .normal)
        }
        
        cell.deleteImageButton.isHidden = true
        cell.deleteImageButton.isUserInteractionEnabled = false
        cell.editImageButton.isHidden = true
        cell.editImageButton.isUserInteractionEnabled = false
        cell.lineView.isHidden = true
        cell.contentView.backgroundColor = .black
        
        return cell
    }
    
    func addImageSelected(atIndex: Int) {
        if atIndex >= 500 {
            let finalIndex = atIndex - 500
            loadWebView(index: finalIndex)
        }else {
            do {
                let client = try SafeClient(wrapping: CraftExchangeClient())
                let vc = ProductCatalogService(client: client).createProdDetailScene(forProduct: suggestedProdArray?[atIndex])
                vc.modalPresentationStyle = .fullScreen
                self.navigationController?.pushViewController(vc, animated: true)
            }catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func deleteImageSelected(atIndex: Int) {
        
    }
    
    func editImageSelected(atIndex: Int) {
        
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "AddPhotoRow") as? CollectionViewRow
        row?.reload()
        row?.cell.collectionView.reloadData()
    }
    
    func downloadProdImages() {
        if isCustom {
            customProduct?.productImages .forEach { (image) in
                let tag = image.lable
                let prodId = customProduct?.entityID
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    self.productImages?.append(downloadedImage)
                    if image == customProduct?.productImages.last {
                        let row = self.form.rowBy(tag: "PhotoRow") as? CollectionViewRow
                        row?.cell.collectionView.reloadData()
                    }
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = CustomProductImageService.init(client: client, productObject: customProduct!, withName: image.lable ?? "name.jpg")
                        service.fetchCustomImage(withName: tag ?? "name.jpg").observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = image.lable ?? "name.jpg"
                                let prodId = self.product?.entityID
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                self.productImages?.append(UIImage.init(data: attachment) ?? UIImage())
                                if image == self.customProduct?.productImages.last {
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
        } else{
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
    
    
    func loadWebView(index: Int) {
        let webView = UIView.init(frame: CGRect.init(x: 0, y: 70, width: self.view.frame.size.width, height: self.view.frame.size.height - 70))
        webView.tag = 333
        
        let wkwebView = WKWebView.init(frame: CGRect.init(x: 0, y: 20, width: self.view.frame.size.width, height: webView.frame.size.height - 20))
        wkwebView.navigationDelegate = self
        wkwebView.uiDelegate = self
        
        if let image = productImages?[index],
            let data = image.pngData() {
            let base64 = data.base64EncodedString(options: [])
            let url = "data:application/png;base64," + base64
            let html = "<html><body><img src='\(url)'><meta name=\"viewport\" content=\"width=device-width, shrink-to-fit=YES\"></body></html>"
            wkwebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: ""))
        }
        wkwebView.contentMode = .scaleAspectFill
        webView.addSubview(wkwebView)
        
        let closeBtn = UIButton.init(type: .custom)
        closeBtn.frame = CGRect.init(x: 20, y: 40, width: 80, height: 30)
        closeBtn.tintColor = .white
        closeBtn.setImage(UIImage.init(systemName: "xmark"), for: .normal)
        closeBtn.setTitle(" Close", for: .normal)
        closeBtn.setTitleColor(.white, for: .normal)
        closeBtn.backgroundColor = .black
        closeBtn.addTarget(self, action: #selector(closeSelected), for: .touchUpInside)
        webView.addSubview(closeBtn)
        
        self.view.addSubview(webView)
        self.view.bringSubviewToFront(webView)
    }
    
    @objc func closeSelected() {
        let view = self.view.viewWithTag(333)
        view?.removeFromSuperview()
    }
}

extension AdminProductDetailController: WKNavigationDelegate, WKUIDelegate {
    
}

