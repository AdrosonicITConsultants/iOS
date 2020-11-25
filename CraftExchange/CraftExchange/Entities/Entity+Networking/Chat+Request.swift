//
//  Chat+Request.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Chat {
    
    static func getChatList() -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        
        var str = "enquiry/getEnquiryMessageChatList"
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
    
    static func getSpecificChat(enquiryId: Int) -> Request<Data, APIError> {
           let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
           
           var str = "marketingTeam/getChatMessages?enquiryId=\(enquiryId)"
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
    
    static func getNewChatList() -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        
        var str = "enquiry/getNewEnquiryMessageChatList"
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
    
    static func fetchChatBrandImage(with userID: Int, name: String) -> Request<Data, APIError> {
        var str = "User/\(userID)/CompanyDetails/Logo/\(name)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,//"Product/10/download.jpg",//
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func initiateChat(enquiryId: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId]
        var str = "enquiry/goToEnquiryChat?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "chat initiation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getConversation(enquiryId: Int) -> Request<Data, APIError> {
      
        var str = "enquiry/getAndReadChatMessageForEnquiry?enquiryId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get conversation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func sendMessage(enquiryId: Int, messageFrom: Int, messageTo: Int, messageString: String, mediaType: Int) -> Request<Data, APIError> {
        
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        let json = ["enquiryId": enquiryId, "messageFrom": messageFrom, "messageTo": messageTo, "messageString": messageString, "mediaType": mediaType] as [String : Any]
        var str = json.jsonString
        
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
            return Request(
            path: "enquiry/sendChatboxMessage?messageJson=\(str)",
            method: .post,
            headers: headers,
            resource: {
                print(String(data: $0, encoding: .utf8) ?? "sending message failed")
                return $0},
            error: APIError.init,
            needsAuthorization: true
            )
       
        
        
    }
    
    public static func sendMedia(enquiryId: Int, messageFrom: Int, messageTo: Int, mediaType: Int,  mediaData: Data?, filename: String?) -> Request<Data, APIError> {
        let json = ["enquiryId": enquiryId, "messageFrom": messageFrom, "messageTo": messageTo, "mediaType": mediaType] as [String : Any]
        var str = json.jsonString
        
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let content = mediaData
        let filename = filename
        
            let boundary = "\(UUID().uuidString)"
        let dataLength = content?.count ?? 0
            let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")", "accept": "application/json","Content-Type": "multipart/form-data; boundary=\(boundary)",
                "Content-Length": String(dataLength) ]
            
            let finalData = MultipartDataHelper().createBody(boundary: boundary, data: content!, mimeType: "application/octet-stream", filename: filename!, param: "file")
            
            return Request(
                path: "enquiry/sendChatboxMessage?messageJson=\(str)",
                method: .post,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: {
                    print(String(data: $0, encoding: .utf8) ?? "sending message failed")
                    return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        
    }
    
    public static func getEscalations() -> Request<Data, APIError> {
        var str = "enquiry/getEscalations"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get escalations failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func getEscalationsSummary(enquiryId: Int) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = "enquiry/getEscalationSummaryForEnquiry?enquiryId=\(enquiryId)"
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
    
    public static func resolveEscalation(enquiryId: Int) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId]
        var str = "enquiry/resolveEscalation?escalationId=\(enquiryId)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "chat initiation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
    
    public static func raiseEscalation(enquiryId: Int, catId: Int, escalationFrom: Int, escalationTo: Int, message: String) -> Request<Data, APIError> {
        let parameters: [String: Any] = ["enquiryId":enquiryId, "category":catId, "escalationFrom":escalationFrom, "escalationTo":escalationTo, "text":message]
        var str = "enquiry/raiseEscalaton"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: str,
            method: .post,
            parameters: JSONParameters(parameters),
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "chat initiation failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
    }
}
