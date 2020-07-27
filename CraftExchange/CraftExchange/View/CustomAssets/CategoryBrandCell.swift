//
//  CategoryBrandCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 23/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class CategoryBrandCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    var delegate: UIViewController!
    
    func configure(_ productCat: ProductCategory) {
        titleLabel.text = productCat.prodCatDescription ?? ""
        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        logoImage.image = UIImage.init(named: productCat.prodCatDescription ?? "Saree")
    }
    
    func configure(_ artisanBrand: User) {
        titleLabel.text = artisanBrand.buyerCompanyDetails.first?.companyName ?? ""
        titleLabel.font = .systemFont(ofSize: 22, weight: .regular)
        logoImage.image = UIImage.init(named: "Saree")
    }
    
    /*
     TODO: Add Brand Logo
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
     */
}

