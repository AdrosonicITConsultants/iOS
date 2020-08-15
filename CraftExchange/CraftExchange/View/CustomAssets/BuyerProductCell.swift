//
//  BuyerProductCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class BuyerProductCell: UITableViewCell {
    @IBOutlet weak var productTag: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var inStock: UILabel!
    @IBOutlet weak var designedByImage: UIImageView!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var wishlistButton: UIButton!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var generateEnquiryButton: UIButton!
    var delegate: UIViewController!
    
    @IBOutlet
    weak var containerView: UIView! {
        didSet {
            containerView.backgroundColor = UIColor.clear
            containerView.layer.shadowColor = UIColor.lightGray.cgColor
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowOffset = CGSize.zero
            containerView.layer.shadowRadius = 5
        }
    }
    
    func configure(_ productObj: Product) {
        viewMoreButton.layer.borderColor = UIColor.lightGray.cgColor
        viewMoreButton.layer.borderWidth = 1
        productTag.text = productObj.productTag ?? ""
        productDesc.text = productObj.productDesc ?? productObj.productSpec ?? ""
        if productObj.productStatusId == 1 {
            inStock.text = "Available in stock".localized
            inStock.textColor = UIColor().CEGreen()
        }else {
            inStock.text = "Exclusively Made to order".localized
            inStock.textColor = .red
        }
        if productObj.madeWithAnthran == 1 {
            designedByImage.image = UIImage.init(named: "iosAntaranSelfDesign")
            productImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        }else {
            designedByImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
            productImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
        }
        if let tag = productObj.productImages.first?.lable {
            let prodId = productObj.entityID
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.productImage.image = downloadedImage
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = ProductImageService.init(client: client, productObject: productObj)
                    service.fetch().observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = productObj.productImages.first?.lable ?? "name.jpg"
                            let prodId = productObj.entityID
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                            self.productImage.image = UIImage.init(data: attachment)
                        }
                    }.dispose(in: delegate?.bag ?? bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func configure(_ productObj: CustomProduct) {
        viewMoreButton.isHidden = true
        generateEnquiryButton.setTitle("Enquiry Now ".localized, for: .normal)
        var nameLbl = ""
        nameLbl = "\(ProductCategory.getProductCat(catId: productObj.productCategoryId)?.prodCatDescription ?? "") / "
        if let warp = Yarn.getYarn(searchId: productObj.warpYarnId) {
            nameLbl.append("\(warp.yarnDesc ?? "")")
        }
        if let weft = Yarn.getYarn(searchId: productObj.weftYarnId) {
            nameLbl.append(" X \(weft.yarnDesc ?? "")")
        }
        if let exWeft = Yarn.getYarn(searchId: productObj.extraWeftYarnId) {
            nameLbl.append(" X \(exWeft.yarnDesc ?? "")")
        }
        productTag.text = nameLbl
        productDesc.text = productObj.productSpec ?? ""
        let formatter = Date.ttceFormatter
        inStock.text = "Created On: \(formatter.string(from: productObj.createdOn ?? Date()))"
        inStock.textColor = UIColor().CEGreen()
        designedByImage.isHidden = true
        productImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        if let tag = productObj.productImages.first?.lable {
            let prodId = productObj.entityID
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.productImage.image = downloadedImage
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = CustomProductImageService.init(client: client, productObject: productObj)
                    service.fetchCustomImage(withName: nil).observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = productObj.productImages.first?.lable ?? "name.jpg"
                            let prodId = productObj.entityID
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                            self.productImage.image = UIImage.init(data: attachment)
                        }
                    }.dispose(in: delegate?.bag ?? bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

