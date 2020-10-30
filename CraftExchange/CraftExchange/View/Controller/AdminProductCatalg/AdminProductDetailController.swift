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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        viewWillAppear?()
        
        form
            +++ Section()
            <<< ProdImagesRow() {
                $0.cell.height = { 300.0 }
            }
            <<< AdminLabelRow(){
                $0.tag = "Product Description"
                $0.cell.AdminLabel.text = "Product Description"
                $0.cell.height = { 40.0 }
            }
            <<< ProdDetailDescriptionRow() {
                let ht = UIView().heightForView(text: product?.productSpec ?? product?.productDesc ?? "", width: self.view.frame.size.width - 200)
                $0.cell.height = { ht < 80 ? 80 : ht+10 }
                print("ht\(ht)")
                $0.cell.backgroundColor = .black
                $0.cell.productDescLbl.text = product?.productSpec ?? product?.productDesc ?? ""
                $0.cell.productDescLbl.textColor = .white
                $0.cell.productDescLbl.numberOfLines = 10
            }
            <<< AdminLabelRow(){
                $0.tag = "Product Details"
                $0.cell.AdminLabel.text = "Product Details"
                $0.cell.height = { 40.0 }
            }
            <<< ProductDetailInfoRow() {
                $0.cell.height = { 100.0 }
                $0.cell.productCatLbl.text = ProductCategory.getProductCat(catId: product?.productCategoryId ?? 0)?.prodCatDescription
                $0.cell.productTypeLbl.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc
                $0.cell.productTypeLbl.text = ClusterDetails.getCluster(clusterId: product?.clusterId ?? 0)?.clusterDescription ?? "-"
                $0.cell.backgroundColor = .black
                if product?.productStatusId == 2 {
                    $0.cell.productAvailabilityLbl.text = "In Stock"
                    $0.cell.productAvailabilityLbl.textColor = UIColor().CEGreen()
                    $0.cell.madeToOrderLbl.isHidden = true
                }
            }
            
          <<< AdminLabelRow(){
                $0.tag = "Weave type used"
                $0.cell.AdminLabel.text = "Weave type used"
                $0.cell.height = { 40.0 }
            }
            <<< ProdDetailDescriptionRow() {
                let ht = UIView().heightForView(text: product?.productSpec ?? product?.productDesc ?? "", width: self.view.frame.size.width - 200)
                $0.cell.height = { ht < 80 ? 80 : ht+10 }
                print("ht\(ht)")
                $0.cell.backgroundColor = .black
                $0.cell.productDescLbl.text = product?.productSpec ?? product?.productDesc ?? ""
                $0.cell.productDescLbl.textColor = .white
                $0.cell.productDescLbl.numberOfLines = 10
            }
            <<< AdminLabelRow(){
                $0.tag = "Weaves used"
                $0.cell.AdminLabel.text = "Weaves used"
                $0.cell.height = { 40.0 }
            }
            <<< ProdDetailYarnRow {
                $0.cell.height = { 100.0 }
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.titleLbl.text = " Yarn"
                $0.cell.backgroundColor = .black
                
                $0.cell.valueLbl1.text = Yarn.getYarn(searchId: product?.warpYarnId ?? 0)?.yarnDesc ?? "-"
                $0.cell.valueLbl2.text = Yarn.getYarn(searchId: product?.weftYarnId ?? 0)?.yarnDesc ?? "-"
                $0.cell.valueLbl3.text = Yarn.getYarn(searchId: product?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-"
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.titleLbl.text = " Yarn \n Count"
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.valueLbl1.text = product?.warpYarnCount ?? "-"
                $0.cell.valueLbl2.text = product?.weftYarnCount ?? "-"
                $0.cell.valueLbl3.text = product?.extraWeftYarnCount ?? "-"
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.titleLbl.text = " Dye"
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.valueLbl1.text = Dye.getDyeType(searchId: product?.warpDyeId ?? 0)?.dyeDesc ?? "-"
                $0.cell.valueLbl2.text = Dye.getDyeType(searchId: product?.weftDyeId ?? 0)?.dyeDesc ?? "-"
                $0.cell.valueLbl3.text = Dye.getDyeType(searchId: product?.extraWeftDyeId ?? 0)?.dyeDesc ?? "-"
            }
            
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "reed count")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Reed count"
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ReedCount.getReedCount(searchId: product?.reedCountId ?? 0)?.count ?? "-"
                $0.cell.valueLbl3.text = ""
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImage.image = UIImage.init(named: "Icon weight")
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.titleLbl.text = "Weight"
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = product?.weight ?? "-"
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
                $0.cell.prodValueLbl.text = "\(product?.weight ?? "-")"
                $0.cell.relatedProdLbl.text = ProductType.getProductType(searchId: product?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                $0.cell.relatedProdValueLbl.text = "\(product?.relatedProducts.first?.weight ?? "-")"
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
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.titleLbl.font = .systemFont(ofSize: 14)
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.valueLbl3.text = "\(product?.length ?? "-") X \(product?.width ?? "-")"
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
                $0.cell.prodValueLbl.text = "\(product?.length ?? "-") X \(product?.width ?? "-")"
                $0.cell.relatedProdLbl.text = ProductType.getProductType(searchId: product?.relatedProducts.first?.entityID ?? 0)?.productDesc ?? "Blouse"
                $0.cell.relatedProdValueLbl.text = "\(product?.relatedProducts.first?.length ?? "-") X \(product?.relatedProducts.first?.width ?? "-")"
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
                $0.cell.titleLbl.textColor = .white
                $0.cell.titleLbl.textAlignment = .center
                $0.cell.titleLbl.font = .systemFont(ofSize: 13)
                $0.cell.valueLbl1.text = ""
                $0.cell.valueLbl2.text = ProductType.getProductType(searchId: product?.productTypeId ?? 0)?.productDesc ?? ""
                $0.cell.valueLbl3.text = product?.gsm ?? "-"
                if $0.cell.valueLbl2.text == "Fabric" {
                    $0.hidden = false
                }else {
                    $0.hidden = true
                }
            }
            <<< AdminLabelRow(){
                $0.tag = "Wash Care Instrustions"
                $0.cell.AdminLabel.text = "Wash Care Instrustions"
                $0.cell.height = { 40.0 }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if productImages?.count ?? 0 == 0 {
            //            downloadProdImages()
            print("AdminProductDetail")
        }
        //        downloadArtisanBrandLogo()
        //        if let prodObj = product {
        //            suggestedProdArray = Product.getSuggestedProduct(forProdId: prodObj.entityID, catId: prodObj.productCategoryId, clusterID: prodObj.clusterId)
        //            let row = self.form.rowBy(tag: "SuggestionRow") as? CollectionViewRow
        //            row?.reload()
        //            row?.cell.collectionView.reloadData()
        //        }
    }
    
}
