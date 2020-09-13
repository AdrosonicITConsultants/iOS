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
import WebKit

class BuyerProductDetailController: FormViewController {

    var product: Product?
    var productImages: [UIImage]? = []
    var showMoreProduct: Int = -1
    var addProdDetailToWishlist: ((_ prodId: Int) -> ())?
    var deleteProdDetailToWishlist: ((_ prodId: Int) -> ())?
    var viewWillAppear: (() -> ())?
    var suggestedProdArray: Results<Product>?
    var checkEnquiry: ((_ prodId: Int) -> ())?
    var generateNewEnquiry: ((_ prodId: Int) -> ())?
    
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
        
        viewWillAppear?()
        
        form
        +++ Section()
            <<< ImageViewRow() {
                $0.tag = "ProductNameRow"
                $0.cell.height = { 130.0 }
                $0.cell.title.text = product?.productTag ?? ""
                $0.cell.productCodeValue.text = product?.code ?? ""
                $0.cell.title.isHidden = false
                $0.cell.productCodeValue.isHidden = false
                $0.cell.productCodeLbl.isHidden = false
                $0.cell.wishlistBtn.isHidden = false
                $0.cell.wishlistBtn.tag = product?.entityID ?? 0
                $0.cell.delegate = self
            }.cellUpdate({ (cell, row) in
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                if appDelegate?.wishlistIds?.contains(where: { (obj) -> Bool in
                    obj == self.product?.entityID
                }) ?? false {
                    cell.wishlistBtn.setImage(UIImage.init(named: "red heart"), for: .normal)
                }else {
                    cell.wishlistBtn.setImage(UIImage.init(named: "tab-wishlist"), for: .normal)
                }
                if User.loggedIn()?.refRoleId == "1" {
                    cell.wishlistBtn.isHidden = true
                }
            })
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
                $0.cell.productTypeLbl.text = ClusterDetails.getCluster(clusterId: product?.clusterId ?? 0)?.clusterDescription ?? "-"
                if product?.productStatusId != 2 {
                    $0.cell.productAvailabilityLbl.text = "In Stock"
                    $0.cell.productAvailabilityLbl.textColor = UIColor().CEGreen()
                    $0.cell.madeToOrderLbl.isHidden = true
                }
            }
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
            }
            <<< LabelRow() {
                $0.cell.height = { 30.0 }
                $0.title = "Artisan brand".localized
            }
            <<< ProdDetailYarnValueRow {
                $0.tag = "ArtisanBrandRow"
                $0.cell.height = { 80.0 }
                $0.cell.titleLbl.isHidden = true
                $0.cell.rowImage.isHidden = false
                $0.cell.rowImageWidthConstraint.constant = 60
                $0.cell.valueLbl1.text = "      "
                $0.cell.valueLbl2.text = "      "
                $0.cell.valueLbl3.text = "      "
            }
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
            }
            <<< ProdDetailYarnRow {
                $0.cell.height = { 100.0 }
            }
            <<< ProdDetailYarnValueRow {
                $0.cell.height = { 100.0 }
                $0.cell.rowImage.isHidden = true
                $0.cell.rowImageWidthConstraint.constant = 0
                $0.cell.titleLbl.text = " Yarn"
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
                $0.cell.valueLbl2.text = ReedCount.getReedCount(searchId: product?.reedCountId ?? 0)?.count ?? "-"
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
                $0.cell.titleLbl.textColor = .black
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
                $0.cell.titleLbl.textColor = .black
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
            <<< LabelRow {
                $0.cell.height = { 1.0 }
                $0.cell.backgroundColor = .lightGray
            }
            <<< washView
            +++ washSection
            +++ Section()
            <<< ImageViewRow() {
                $0.cell.height = { 80.0 }
                $0.cell.cellImage.image = UIImage.init(named: "like_it")
            }
            <<< LabelRow() {
                $0.title = "More \(ProductCategory.getProductCat(catId: product?.productCategoryId ?? 0)?.prodCatDescription ?? "Items") from \(ClusterDetails.getCluster(clusterId: product?.clusterId ?? 0)?.clusterDescription ?? "-")"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textAlignment = .center
                cell.textLabel?.textColor = .lightGray
            })
            <<< CollectionViewRow() {
                $0.tag = "SuggestionRow"
                
                $0.cell.collectionView.register(UINib(nibName: "ImageSelectorCell", bundle: nil), forCellWithReuseIdentifier: "ImageSelectorCell")
                $0.cell.collectionDelegate = self
                $0.cell.collectionView.tag = 2002
                $0.cell.height = { 280.0 }
            }
            <<< ButtonRow() {
                $0.title = "Genrate Enquiry"
                if User.loggedIn()?.refRoleId == "1" {
                    $0.hidden = true
                }
            }.cellUpdate({ (cell, row) in
                cell.backgroundColor = .black
                cell.tintColor = .white
            }).onCellSelection({ (cell, row) in
                self.checkEnquiry?(self.product?.entityID ?? 0)
            })
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if productImages?.count ?? 0 == 0 {
            downloadProdImages()
        }
        downloadArtisanBrandLogo()
        if let prodObj = product {
            suggestedProdArray = Product.getSuggestedProduct(forProdId: prodObj.entityID, catId: prodObj.productCategoryId, clusterID: prodObj.clusterId)
            let row = self.form.rowBy(tag: "SuggestionRow") as? CollectionViewRow
            row?.reload()
            row?.cell.collectionView.reloadData()
        }
    }
    
}

extension BuyerProductDetailController: ProdDetailWishlistProtocol {
    func addToWishlist(prodId: Int) {
        print("add to wishlist")
        addProdDetailToWishlist?(prodId)
    }
    
    func deleteProdWishlist(prodId: Int) {
        print("delete from wishlist")
        deleteProdDetailToWishlist?(prodId)
    }
}

extension BuyerProductDetailController: UICollectionViewDelegate, UICollectionViewDataSource, AddImageProtocol {

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
        cell.contentView.backgroundColor = .white
        
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
    
    func downloadArtisanBrandLogo() {
        let artist = User.getUser(userId: product?.artitionId ?? 0)
        if let tag = artist?.buyerCompanyDetails.first?.logo, artist?.buyerCompanyDetails.first?.logo != "" {
            let prodId = artist?.entityID ?? 0
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.updateArtistLogo(image: downloadedImage)
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = BrandLogoService.init(client: client, userObject: (artist)!)
                    service.fetch().observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = artist?.buyerCompanyDetails.first?.logo ?? "name.jpg"
                            let prodId = artist?.entityID ?? 0
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                            self.updateArtistLogo(image:UIImage.init(data: attachment) ?? UIImage.init(named: "person_icon")!)
                        }
                    }.dispose(in: self.bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
        else if let tag = artist?.profilePic, artist?.profilePic != "" {
            let prodId = artist?.entityID ?? 0
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.updateArtistLogo(image: downloadedImage)
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = UserProfilePicService.init(client: client, userObject: (artist)!)
                    service.fetch().observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = artist?.profilePic ?? "name.jpg"
                            let prodId = artist?.entityID ?? 0
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                            self.updateArtistLogo(image:UIImage.init(data: attachment) ?? UIImage.init(named: "person_icon")!)
                        }
                    }.dispose(in: self.bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateArtistLogo(image: UIImage) {
        let row = form.rowBy(tag: "ArtisanBrandRow") as? ProdDetailYarnValueRow
        row?.cell.rowImage.image = image
        row?.updateCell()
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

extension BuyerProductDetailController: WKNavigationDelegate, WKUIDelegate {
    
}

extension BuyerProductDetailController: EnquiryExistsViewProtocol, EnquiryGeneratedViewProtocol {
    func closeButtonSelected() {
        self.view.hideEnquiryGenerateView()
    }
    
    func viewEnquiryButtonSelected(enquiryId: Int) {
        self.view.hideEnquiryGenerateView()
    }
    
    func cancelButtonSelected() {
        self.view.hideEnquiryExistsView()
    }
    
    func viewEnquiryButtonSelected() {
        self.view.hideEnquiryExistsView()
    }
    
    func generateEnquiryButtonSelected(prodId: Int) {
        self.generateNewEnquiry?(prodId)
        self.view.hideEnquiryExistsView()
    }
}
