//
//  EnquiryDetailRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 07/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class EnquiryDetailRowView: Cell<String>, CellType {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var prodDetailLbl: UILabel!
    @IBOutlet weak var designByLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var statusDotView: UIView!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var faultyStrings: UIImageView!
    public override func setup() {
        super.setup()
        faultyStrings.isHidden = true
    }
    
    public override func update() {
        super.update()
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class EnquiryDetailsRow: Row<EnquiryDetailRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<EnquiryDetailRowView>(nibName: "EnquiryDetailsRow")
    }
}

extension EnquiryDetailsRow {
    func configureRow(orderObject: Order?, enquiryObject: Enquiry?) {
        self.tag = "EnquiryDetailsRow"
        self.cell.height = { 220.0 }
        self.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: orderObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: orderObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: orderObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: orderObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
        if orderObject?.productType == "Custom Product" {
            if orderObject?.brandName?.isNotBlank ?? false {
                self.cell.designByLbl.text = orderObject?.brandName ?? "Requested Custom Design"
            }else{
                self.cell.designByLbl.text = "Requested Custom Design"
            }
        }else {
            self.cell.designByLbl.text = orderObject?.brandName
        }
        self.cell.amountLbl.text = orderObject?.totalAmount != 0 ? "\(orderObject?.totalAmount ?? 0)" : "NA"
    }
    
    func cellUpdate(orderObject: Order?, enquiryObject: Enquiry?) {
//        cell.statusLbl.text = "\(EnquiryStages.getStageType(searchId: orderObject?.enquiryStageId ?? 0)?.stageDescription ?? "-")"
//        if orderObject?.enquiryStageId ?? 0 < 5 {
//            cell.statusLbl.textColor = .black
//            cell.statusDotView.backgroundColor = .black
//        }else if orderObject?.enquiryStageId ?? 0 < 9 {
//            cell.statusLbl.textColor = .systemYellow
//            cell.statusDotView.backgroundColor = .systemYellow
//        }else {
//            cell.statusLbl.textColor = UIColor().CEGreen()
//            cell.statusDotView.backgroundColor = UIColor().CEGreen()
//        }
        if let date = orderObject?.lastUpdated {
            cell.dateLbl.text = "Last updated: \(Date().ttceISOString(isoDate: date))"
        }
    }
    
    func loadRowImage(orderObject: Order?, enquiryObject: Enquiry?) {
        if orderObject?.productType ?? enquiryObject?.productType == "Custom Product" {
            if orderObject?.brandName?.isNotBlank ?? enquiryObject?.brandName?.isNotBlank ?? false {
                self.cell.designByLbl.text = orderObject?.brandName ?? enquiryObject?.brandName ?? "Requested Custom Design"
            }else{
                self.cell.designByLbl.text = "Requested Custom Design"
            }
        }else {
            self.cell.designByLbl.text = orderObject?.brandName ?? enquiryObject?.brandName
        }
        if let tag = orderObject?.productImages?.components(separatedBy: ",").first ?? enquiryObject?.productImages?.components(separatedBy: ",").first , let prodId = orderObject?.productId ?? enquiryObject?.productId{
            if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                self.cell.productImage.image = downloadedImage
            }else {
                if orderObject?.productType == "Custom Product" {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = CustomProductImageService.init(client: client)
                        service.fetchCustomImage(withName: tag, prodId: prodId).observeNext { (attachment) in
                            DispatchQueue.main.async {
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                self.cell.productImage.image = UIImage.init(data: attachment)
                                self.reload()
                            }
                        }.dispose()
                    }catch {
                        print(error.localizedDescription)
                    }
                }else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = ProductImageService.init(client: client)
                        service.fetch(withId: prodId, withName: tag).observeNext { (attachment) in
                            DispatchQueue.main.async {
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                self.cell.productImage.image = UIImage.init(data: attachment)
                                self.reload()
                            }
                        }.dispose()
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }

    }
}
