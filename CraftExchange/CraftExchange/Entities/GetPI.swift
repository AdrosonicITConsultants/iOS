//
//  GetPI.swift
//  CraftExchange
//
//  Created by Kalyan on 29/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class GetPI: Object, Decodable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var enquiryId: Int = 0
    @objc dynamic var orderId: Int = 0
    @objc dynamic var artisanId: Int = 0
    @objc dynamic var date: String?
    @objc dynamic var orderName: String?
    @objc dynamic var productCode: String?
    @objc dynamic var quantity: Int = 0
    @objc dynamic var ppu: Int = 0
    @objc dynamic var expectedDateOfDelivery: String?
    @objc dynamic var totalAmount: Int = 0
    @objc dynamic var hsn: Int = 0
    @objc dynamic var cgst: Int = 0
    @objc dynamic var sgst: Int = 0
    @objc dynamic var isSend: Int = 0
    @objc dynamic var createdOn: String?
    @objc dynamic var modifiedOn: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case enquiryId = "enquiryId"
        case orderId = "orderId"
        case artisanId = "artisanId"
        case date = "date"
        case orderName = "orderName"
        case productCode = "productCode"
        case quantity = "quantity"
        case ppu = "ppu"
        case expectedDateOfDelivery = "expectedDateOfDelivery"
        case totalAmount = "totalAmount"
        case hsn = "hsn"
        case cgst = "cgst"
        case sgst = "sgst"
        case isSend = "isSend"
        case createdOn = "createdOn"
        case modifiedOn = "modifiedOn"
        
    }
    
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try (values.decodeIfPresent(Int.self, forKey: .id) ?? 0)
        enquiryId = try (values.decodeIfPresent(Int.self, forKey: .enquiryId) ?? 0)
        orderId = try (values.decodeIfPresent(Int.self, forKey: .orderId) ?? 0)
        artisanId = try (values.decodeIfPresent(Int.self, forKey: .artisanId) ?? 0)
        date = try values.decodeIfPresent(String.self, forKey: .date)
        orderName = try values.decodeIfPresent(String.self, forKey: .orderName)
        productCode = try values.decodeIfPresent(String.self, forKey: .productCode)
        quantity = try (values.decodeIfPresent(Int.self, forKey: .quantity) ?? 0)
        ppu = try (values.decodeIfPresent(Int.self, forKey: .ppu) ?? 0)
        expectedDateOfDelivery = try values.decodeIfPresent(String.self, forKey: .expectedDateOfDelivery)
        totalAmount = try (values.decodeIfPresent(Int.self, forKey: .totalAmount) ?? 0)
        hsn = try (values.decodeIfPresent(Int.self, forKey: .hsn) ?? 0)
        cgst = try (values.decodeIfPresent(Int.self, forKey: .cgst) ?? 0)
        sgst = try (values.decodeIfPresent(Int.self, forKey: .sgst) ?? 0)
        isSend = try (values.decodeIfPresent(Int.self, forKey: .isSend) ?? 0)
        createdOn = try values.decodeIfPresent(String.self, forKey: .createdOn)
        modifiedOn = try values.decodeIfPresent(String.self, forKey: .modifiedOn)
        
    }
}



