//
//  Enquiry+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 01/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Enquiry {
    
    static func checkIfEnquiryExists(for prodId: Int, isCustom: Bool) -> Request<Data, APIError> {
        var str = "enquiry/ifEnquiryExists/\(prodId)/\(isCustom)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func generateEnquiry(productId: Int, isCustom: Bool) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["productId":productId,
                                         "isCustom": isCustom,
                                         "deviceName":"IOS"]
        var str = "enquiry/generateEnquiry/\(productId)/\(isCustom)/IOS"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "generateEnquiry failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getEnquiryStages() -> Request<Data, APIError> {
        var str = "enquiry/getAllEnquiryStages"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getOpenEnquiries() -> Request<Data, APIError> {
        var str = "enquiry/getOpenEnquiries"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getOpenEnquiryDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getEnquiry/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    static func getPreviewPI(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getPreviewPiHTML?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    public static func savePI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int,  ppu: Int, quantity: Int,sgst: Int) -> Request<Data, APIError> {
        
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "cgst": cgst,
                                         "expectedDateOfDelivery": expectedDateOfDelivery,
                                         "hsn": hsn,
                                         "ppu": ppu,
                                         "quantity": quantity,
                                         "sgst": sgst]
        var str = "enquiry/savePi/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "markInvoiceCompleted failed")
            return $0},
            error: APIError.init,
            needsAuthorization: false
            
        )
        
    }
    public static func sendPI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int,  ppu: Int, quantity: Int,sgst: Int) -> Request<Data, APIError> {
        
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "cgst": cgst,
                                         "expectedDateOfDelivery": expectedDateOfDelivery,
                                         "hsn": hsn,
                                         "ppu": ppu,
                                         "quantity": quantity,
                                         "sgst": sgst]
        var str = "enquiry/sendPi/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "sendingPI failed")
            return $0},
            error: APIError.init,
            needsAuthorization: false
            
        )
        
    }
    static func getClosedEnquiries() -> Request<Data, APIError> {
        var str = "enquiry/getClosedEnquiries"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getClosedEnquiryDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getClosedEnquiry/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func closeEnquiry(enquiryId: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId]
        return Request(
            path: "enquiry/markEnquiryCompleted/\(enquiryId)",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "markEnquiryCompleted failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
}
