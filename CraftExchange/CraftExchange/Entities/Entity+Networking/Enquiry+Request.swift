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
    
    static func getEnquiryInnerStages() -> Request<Data, APIError> {
        var str = "enquiry/getAllInnerEnquiryStages"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    static func getAvailableProductEnquiryStages() -> Request<Data, APIError> {
        var str = "enquiry/getEnquiryStagesForAvailableProduct"
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
    public static func closeOrder(enquiryId: Int) -> Request<Data, APIError> {
        var str = "order/initializePartialRefund?orderId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    public static func markOrderAsReceived(orderId: Int, orderRecieveDate: String, isAutoCompleted: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["orderId":orderId, "orderRecieveDate":orderRecieveDate, "isAutoCompleted":isAutoCompleted]
        return Request(
            path: "enquiry/markOrderAsRecieved/\(orderId)/\(orderRecieveDate)/\(isAutoCompleted)",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "mark order as received failed")
                return $0},
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
    
    public static func sendFinalInvoice(enquiryId: String, advancePaidAmount: String, finalTotalAmount: Int, quantity: Int, ppu: Int, cgst: String , sgst: String, deliveryCharges: String ) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId,
                                         "advancePaidAmt": advancePaidAmount,
                                         "finalTotalAmt": finalTotalAmount,
                                         "quantity": quantity,
                                         "ppu": ppu,
                                         "cgst": cgst,
                                         "sgst": sgst,
                                         "deliveryCharges": deliveryCharges
                                        ]
        return Request(
            path: "enquiry/generateTaxInvoice",
            method: .post,
            parameters: JSONParameters(parameters),
            resource: {print(String(data: $0, encoding: .utf8) ?? "sending final invoice failed")
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
    
    public static func getPreviewPI(enquiryId: Int, isOld: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")",  "accept": "text/html"]
        var str = "enquiry/getPreviewPiHTML?enquiryId=\(enquiryId)&isOld=\(isOld)"
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
        var str = "enquiry/getPreviewPiPDF?enquiryId=\(enquiryId)"
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
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getCurrencySigns"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func uploadReceipt(enquiryId: Int, type: Int, paidAmount: Int, percentage: Int,invoiceId: Int, pid: Int, totalAmount: Int , imageData: Data?, filename: String?) -> Request<Data, APIError> {
        var json: [String: Any] = [:]
        if percentage == 0{
            json = ["enquiryId": enquiryId, "type": type, "paidAmount": paidAmount,"invoiceId": invoiceId,  "pid": pid, "totalAmount": totalAmount]
        }else{
           json = ["enquiryId": enquiryId, "type": type, "paidAmount": paidAmount, "percentage": percentage, "pid": pid, "totalAmount": totalAmount]
        }
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
    
    public static func uploadDeliveryChallan(enquiryId: Int,orderDispatchDate: String, ETA: String, imageData: Data?, filename: String?) -> Request<Data, APIError> {
        var str = "enquiry/submitDeliveryChallan?enquiryId=\(enquiryId)&orderDispatchDate=\(orderDispatchDate)&ETA=\(ETA)"
           if ETA == "0"{
               str = "enquiry/submitDeliveryChallan?enquiryId=\(enquiryId)&orderDispatchDate=\(orderDispatchDate)"
           }
         
           str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
           let content = imageData
           let filename = filename
           let boundary = "\(UUID().uuidString)"
           let dataLength = content!.count
           let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")", "accept": "application/json","Content-Type": "multipart/form-data; boundary=\(boundary)",
               "Content-Length": String(dataLength) ]
           
           let finalData = MultipartDataHelper().createBody(boundary: boundary, data: content!, mimeType: "application/octet-stream", filename: filename!, param: "file")
           
           return Request(
               path: str,
               method: .post,
               parameters: DataParameter(finalData),
               headers: headers,
               resource: {
                   print(String(data: $0, encoding: .utf8) ?? "uploading delivery challan failed")
                   return $0},
               error: APIError.init,
               needsAuthorization: true
           )
           
       }
    public static func ReceivedReceit(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getAdvancedPaymentReceipt/\(enquiryId)?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    public static func FinalPaymentReceit(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getFinalPaymentReceipt/\(enquiryId)?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getAdvancePaymentStatus(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getAdvancedPaymentStatus?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getFinalPaymentDetails(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getPaymentDetailsForFinalPayment?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getFinalPaymentStatus(enquiryId: Int) -> Request<Data, APIError> {
        var str = "enquiry/getFinalPaymentStatus?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func validateAdvancePayment(enquiryId: Int, status: Int) -> Request<Data, APIError> {
        
        var str = "enquiry/validateAdvancePaymentFromArtisan?enquiryId=\(enquiryId)&status=\(status)"
            str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                  let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        
           return Request(
             path: str,
               method: .put,
               headers: headers,
               resource: {print(String(data: $0, encoding: .utf8) ?? "validating advance payment failed")
                 return $0},
               error: APIError.init,
               needsAuthorization: true
           )
       }
    
    public static func validateFinalPayment(enquiryId: Int, status: Int) -> Request<Data, APIError> {
     
     var str = "enquiry/validateFinalPaymentFromArtisan?enquiryId=\(enquiryId)&status=\(status)"
         str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
               let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
     
        return Request(
          path: str,
            method: .put,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "validating final payment failed")
              return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
 
    
    public static func changeInnerStage(enquiryId: Int, stageId: Int, innerStageId: Int) -> Request<Data, APIError> {
        var str = ""
        if innerStageId == 0{
            str = "enquiry/setEnquiryOrderStages/\(stageId)/\(enquiryId)/ "
        }else{
            str = "enquiry/setEnquiryOrderStages/\(stageId)/\(enquiryId)/\(innerStageId)?innerStageId=\(innerStageId)"
        }
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                 let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "changing Inner stage failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
          )
      }
}
