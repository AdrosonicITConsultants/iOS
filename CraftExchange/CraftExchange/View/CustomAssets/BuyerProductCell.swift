//
//  BuyerProductCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

@objc protocol WishlistProtocol {
    @objc optional func wishlistSelected(prodId: Int)
    @objc optional func removeFromWishlist(prodId: Int)
}

class BuyerProductCell: UITableViewCell {
    @IBOutlet weak var productTag: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var inStock: UILabel!
    @IBOutlet weak var designedByImage: UIImageView!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var wishlistButton: UIButton!
    @IBOutlet weak var viewMoreButton: UIButton!
    @IBOutlet weak var generateEnquiryButton: UIButton!
    var delegate: WishlistProtocol?
    
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
    
    func configure(_ productObj: Product, byAntaran: Bool) {
        viewMoreButton.layer.borderColor = UIColor.lightGray.cgColor
        viewMoreButton.layer.borderWidth = 1
        wishlistButton.tag = productObj.entityID
        productTag.text = productObj.productTag ?? ""
        productDesc.text = productObj.productDesc ?? productObj.productSpec ?? ""
        if productObj.productStatusId == 1 {
            inStock.text = "Available in stock".localized
            inStock.textColor = UIColor().CEGreen()
        }else {
            inStock.text = "Exclusively Made to order".localized
            inStock.textColor = .red
        }
        if byAntaran == true {
            designedByImage.image = UIImage.init(named: "iosAntaranSelfDesign")
            productImage.image = UIImage.init(named: "iosAntaranSelfDesign")
        }else {
            designedByImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
            productImage.image = UIImage.init(named: "ArtisanSelfDesigniconiOS")
        }
        if KeychainManager.standard.wishlistIds?.contains(where: { (obj) -> Bool in
            (obj as? Int) == productObj.entityID
        }) ?? false {
            wishlistButton.setImage(UIImage.init(named: "red heart"), for: .normal)
        }else {
            wishlistButton.setImage(UIImage.init(named: "tab-wishlist"), for: .normal)
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
                    }.dispose(in: (delegate as? UIViewController)?.bag ?? bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func wishlistSelected(_ sender: Any) {
        if KeychainManager.standard.wishlistIds?.contains(where: { (obj) -> Bool in
            (obj as? Int) == wishlistButton.tag
        }) ?? false {
            wishlistButton.setImage(UIImage.init(named: "tab-wishlist"), for: .normal)
            delegate?.removeFromWishlist?(prodId: wishlistButton.tag)
        }else {
            wishlistButton.setImage(UIImage.init(named: "red heart"), for: .normal)
            delegate?.wishlistSelected?(prodId: wishlistButton.tag)
        }
    }
}

