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
    
    public static func sendMOQ(enquiryId: Int, additionalInfo: String, deliveryTimeId: Int, moq: Int, ppu: String) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "additionalInfo": additionalInfo,
                                         "deliveryTimeId": deliveryTimeId,
                                         "moq": moq,
                                         "ppu": ppu]
        return Request(
            path: "enquiry/sendMoq/\(enquiryId)",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "send MOQ failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func savePI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int, ppu: Int, quantity: Int, sgst: Int ) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "cgst": cgst,
                                         "expectedDateOfDelivery": expectedDateOfDelivery,
                                         "hsn": hsn,
                                         "ppu": ppu,
                                         "quantity": quantity,
                                         "sgst": sgst]
        return Request(
            path: "enquiry/savePi/\(enquiryId)",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "save PI failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func sendPI(enquiryId: Int, cgst: Int, expectedDateOfDelivery: String, hsn: Int, ppu: Int, quantity: Int, sgst: Int ) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "cgst": cgst,
                                         "expectedDateOfDelivery": expectedDateOfDelivery,
                                         "hsn": hsn,
                                         "ppu": ppu,
                                         "quantity": quantity,
                                         "sgst": sgst]
        return Request(
            path: "enquiry/sendPi/\(enquiryId)",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "save PI failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func acceptMOQ(enquiryId: Int, moqId: Int, artisanId: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "moqId": moqId,
                                         "artisanId": artisanId]
        return Request(
            path: "enquiry/MoqSelected/\(enquiryId)/\(moqId)/\(artisanId)",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "accept MOQ failed")
                return $0},
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    
    public static func getMOQs(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getMoqs/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get MOQs failed")
                
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getMOQ(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getMoq/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get MOQ failed")
                
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getPI(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getPi/\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get PI failed")
                
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getPreviewPI(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")",  "accept": "text/html"]
        var str = "enquiry/getPreviewPiHTML?enquiryId=\(enquiryId)&isOld=false"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get preview PI failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func downloadPreviewPI(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")",  "accept": "application/pdf"]
        var str = "enquiry/getPreviewPiPDF?enquiryId=\(enquiryId)&isOld=false"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "download preview PI failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public  static func getMOQDeliveryTimes() -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getMoqDeliveryTimes"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public  static func getCurrencySigns() -> Request<Data, APIError> {
        var str = "enquiry/getCurrencySigns"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func uploadReceipt(enquiryId: Int, type: Int, paidAmount: Int, percentage: Int, pid: Int, totalAmount: Int , imageData: Data?, filename: String?) -> Request<Data, APIError> {

        let json = ["enquiryId": enquiryId, "type": type, "paidAmount": paidAmount, "percentage": percentage, "pid": pid, "totalAmount": totalAmount]
        var str = json.jsonString
        
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let content = imageData
        let filename = filename
            let boundary = "\(UUID().uuidString)"
        let dataLength = content!.count
            let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")", "accept": "application/json","Content-Type": "multipart/form-data; boundary=\(boundary)",
            "Content-Length": String(dataLength) ]

        let finalData = MultipartDataHelper().createBody(boundary: boundary, data: content!, mimeType: "application/octet-stream", filename: filename!, param: "file")

            return Request(
                path: "enquiry/Payment?payment=\(str)",
                method: .post,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: {
                    print(String(data: $0, encoding: .utf8) ?? "uploading transaction failed")
                    return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        
    }
   public static func ReceivedReceit(enquiryId: Int) -> Request<Data, APIError> {

        var str = "enquiry/getAdvancedPaymentReceipt/\(enquiryId)?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
}
