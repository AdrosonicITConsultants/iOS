//
//  ArtisanProductCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 20/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class ArtisanProductCell: UITableViewCell {
    @IBOutlet weak var productTag: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var inStock: UILabel!
    @IBOutlet weak var exclusive: UILabel!
    @IBOutlet weak var designedByImage: UIImageView!
    @IBOutlet weak var productDesc: UILabel!
    var delegate: UIViewController!
    
    func configure(_ productObj: Product) {
        productTag.text = productObj.productTag ?? ""
        productDesc.text = productObj.productSpec ?? ""
        if productObj.productStatusId == 1 {
            inStock.isHidden = true
            exclusive.isHidden = false
        }else {
            inStock.isHidden = false
            exclusive.isHidden = true
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
}
