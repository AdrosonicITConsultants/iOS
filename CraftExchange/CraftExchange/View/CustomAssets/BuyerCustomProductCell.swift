//
//  BuyerCustomProductCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

protocol CustomProductCellProtocol {
    func deleteCustomProduct(withId: Int)
    func generateCustomProdEnquiry(prodId: Int)
}

class BuyerCustomProductCell: UITableViewCell {
    @IBOutlet weak var productTag: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var createdBy: UILabel!
    @IBOutlet weak var productDesc: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var generateEnquiryButton: UIButton!
    var delegate: CustomProductCellProtocol?
    
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
    
    func configure(_ productObj: CustomProduct) {
        deleteButton.tag = productObj.entityID
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
        createdBy.text = "Created On: \(formatter.string(from: productObj.createdOn ?? Date()))"
        createdBy.textColor = UIColor().CEGreen()
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
                    }.dispose(in: (delegate as? UIViewController)?.bag ?? bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    @IBAction func deleteCustomProdSelected(_ sender: Any) {
        delegate?.deleteCustomProduct(withId: (sender as? UIButton)?.tag ?? 0)
    }
    
    @IBAction func enquireNowSelected(_ sender: Any) {
        delegate?.generateCustomProdEnquiry(prodId: deleteButton.tag)
    }
}

