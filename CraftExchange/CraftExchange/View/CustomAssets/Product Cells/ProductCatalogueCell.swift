//
//  ProductCatalogueCell.swift
//  CraftExchange
//
//  Created by Kalyan on 19/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation

@objc protocol ProductCatalogueProtocol {
}

class ProductCatalogueCell: UITableViewCell {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productCode: UILabel!
    @IBOutlet weak var totalOrdersCount: UILabel!
    @IBOutlet weak var productAddedDate: UILabel!
    @IBOutlet weak var availabilityImage: UIImageView!
    @IBOutlet weak var productBrand: UILabel!
    @IBOutlet weak var productcategory: UILabel!
     var delegate: ProductCatalogueProtocol?
    
     func configure(_ productObj: CatalogueProduct) {
        productName.text = productObj.name ?? ""
        productCode.text = productObj.code ?? ""
        totalOrdersCount.text = "\(productObj.orderGenerated)"
        productAddedDate.text = Date().ttceFormatter2(isoDate: productObj.dateAdded ?? "")
        productBrand.text = productObj.brand ?? "NA"
        productcategory.text = productObj.category ?? ""
        if productObj.availability == "Available in Stock" {
            availabilityImage.image = UIImage.init(named: "ios available in stock")
        }
        if productObj.availability == "Made to order" {
            availabilityImage.image = UIImage.init(named: "ios scissor")
        }
        if let tag = productObj.images {
            let prodId = productObj.entityID
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.productImage.image = downloadedImage
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = AdminProductImageService.init(client: client, productObject: productObj)
                    service.fetch().observeNext { (attachment) in
                        DispatchQueue.main.async {
                            let tag = productObj.images ?? "name.jpg"
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
    
}
