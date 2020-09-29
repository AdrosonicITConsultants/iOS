//
//  BuyerEnquiryCell.swift
//  CraftExchange
//
//  Created by Preety Singh on 04/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class BuyerEnquiryCell: UITableViewCell {
    @IBOutlet weak var enquiryCodeLabel: UILabel!
    @IBOutlet weak var prodDetailLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusDot: UIView!
    @IBOutlet weak var prodImage: UIImageView!
    @IBOutlet weak var requestMOQLabel: UILabel!
    
    func configure(_ enquiryObj: Enquiry) {
        enquiryCodeLabel.text = enquiryObj.enquiryCode
        prodDetailLabel.text = "\(ProductCategory.getProductCat(catId: enquiryObj.productCategoryId)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObj.warpYarnId)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObj.weftYarnId)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObj.extraWeftYarnId)?.yarnDesc ?? "-")"
        if enquiryObj.productType == "Custom Product" {
            brandLabel.text = "Requested Custom Design"
        }else {
            brandLabel.text = enquiryObj.brandName
        }
        if enquiryObj.productStatusId == 2 {
            availabilityLabel.text = "Available in stock"
        }else {
            availabilityLabel.text = "Make to order"
        }
        costLabel.text = enquiryObj.totalAmount != 0 ? "₹ \(enquiryObj.totalAmount)" : "NA"
        dateLabel.text = "Updated on: \(enquiryObj.lastUpdated?.split(separator: "T").first ?? "")"
        statusLabel.text = "\(EnquiryStages.getStageType(searchId: enquiryObj.enquiryStageId)?.stageDescription ?? "-")"
        if enquiryObj.enquiryStageId < 5 {
            statusLabel.textColor = .black
            statusDot.backgroundColor = .black
        }else if enquiryObj.enquiryStageId < 9 {
            statusLabel.textColor = .systemYellow
            statusDot.backgroundColor = .systemYellow
        }else {
            statusLabel.textColor = UIColor().CEGreen()
            statusDot.backgroundColor = UIColor().CEGreen()
        }
        if User.loggedIn()?.refRoleId == "1" && enquiryObj.enquiryStageId == 1 && enquiryObj.isMoqSend == 0 {
            requestMOQLabel.isHidden = false
        }else {
            requestMOQLabel.isHidden = true
        }
        
        
        if let tag = enquiryObj.productImages?.components(separatedBy: ",").first {
            if let downloadedImage = try? Disk.retrieve("\(enquiryObj.productId)/\(tag)", from: .caches, as: UIImage.self) {
            self.prodImage.image = downloadedImage
        }else {
            if enquiryObj.productType == "Custom Product" {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = CustomProductImageService.init(client: client)
                    service.fetchCustomImage(withName: enquiryObj.productImages?.components(separatedBy: ",").first ?? "name", prodId: enquiryObj.productId).observeNext { (attachment) in
                        DispatchQueue.main.async {
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(enquiryObj.productId)/\(tag)")
                            self.prodImage.image = UIImage.init(data: attachment)
                        }
                    }.dispose(in: bag)
                }catch {
                    print(error.localizedDescription)
                }
            }else {
                do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = ProductImageService.init(client: client)
                    service.fetch(withId: enquiryObj.productId, withName: enquiryObj.productImages?.components(separatedBy: ",").first ?? "name").observeNext { (attachment) in
                        DispatchQueue.main.async {
                            _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(enquiryObj.productId)/\(tag)")
                            self.prodImage.image = UIImage.init(data: attachment)
                        }
                    }.dispose(in: bag)
                }catch {
                    print(error.localizedDescription)
                }
            }
        }
        }
    }
}
