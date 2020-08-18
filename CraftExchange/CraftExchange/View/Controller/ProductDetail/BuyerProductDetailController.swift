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
                $0.cell.height = { 40.0 }
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
                $0.title = "Product Details"
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
