//
//  CustomeProduct+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension CustomProduct {
  
    public static func getAllBuyersCustomProduct() -> Request<Data, APIError> {
        //
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "buyerCustomProduct/getAllProducts",
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get all buyers custom product failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
      }
    
    public static func getCustomProductDetails(custProdId: Int) -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "marketingTeam/getCustomProduct/\(custProdId)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get custom product details failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getCustomProductDetails2(custProdId: Int) -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "buyerCustomProduct/getProduct/\(custProdId)",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get custom product details failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }

    static func fetchCustomProductImage(with productId: Int, imageName: String) -> Request<Data, APIError> {
        var str = "CustomProduct/\(productId)/\(imageName)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,//"Product/10/download.jpg",//
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func uploadCustomProduct(json: [String: Any], imageData: [(String,Data)]) -> Request<Data, APIError> {
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        var str = json.jsonString
        print("product: \n\n \(str)")
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if imageData.count > 0 {
            let boundary = "\(UUID().uuidString)"
            var dataLength = 0
            imageData .forEach { (imgData) in
                dataLength = dataLength + imgData.1.count
            }
            let headers: [String: String] = ["Content-Type": "multipart/form-data; boundary=\(boundary)",
                                             "accept": "application/json",
                                             "Content-Length": String(dataLength)
            ]
            let finalData = MultipartDataHelper().createBody(boundary: boundary, mimeType: "application/octet-stream", imageData: imageData)
            return Request(
                path: "buyerCustomProduct/uploadProduct?productData=\(str)",
                method: .post,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: {
                    print(String(data: $0, encoding: .utf8) ?? "artisan upload product failed")
                    return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }else {
            return Request(
                path: "buyerCustomProduct/uploadProduct?productData=\(str)",
                method: .post,
                headers: headers,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artisan upload product failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }
    }
    
    
    public static func editCustomProduct(json: [String: Any], imageData: [(String,Data)]) -> Request<Data, APIError> {
        var str = json.jsonString
        print("product: \n\n \(str)")
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        if imageData.count > 0 {
            let boundary = "\(UUID().uuidString)"
            var dataLength = 0
            imageData .forEach { (imgData) in
                dataLength = dataLength + imgData.1.count
            }
            let headers: [String: String] = ["Content-Type": "multipart/form-data; boundary=\(boundary)",
                                             "accept": "application/json",
                                             "Content-Length": String(dataLength),
                                             "Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"
            ]
            let finalData = MultipartDataHelper().createBody(boundary: boundary, mimeType: "application/octet-stream", imageData: imageData)
            return Request(
                path: "buyerCustomProduct/edit/product?productData=\(str)",
                method: .put,
                parameters: DataParameter(finalData),
                headers: headers,
                resource: {
                    print(String(data: $0, encoding: .utf8) ?? "artisan edit product failed")
                    return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }else {
            return Request(
                path: "buyerCustomProduct/edit/product?productData=\(str)",
                method: .put,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artisan edit product failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }
    }
    
    
    public static func deleteCustomProduct(withId: Int) -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "buyerCustomProduct/deleteProduct/\(withId)",
          method: .delete,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "delete buyers custom product failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func deleteAllCustomProducts() -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "buyerCustomProduct/deleteAllProducts",
          method: .delete,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "delete all buyers custom product failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }

}
