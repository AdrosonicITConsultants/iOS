//
//  Product+Request.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//
import UIKit
import Foundation
import Realm
import RealmSwift
import Eureka

extension Product {
  
    public static func getAllArtisanProduct() -> Request<Data, APIError> {
        //
        let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
        return Request(
            path: "product/getArtitionProducts",
            method: .get,
            headers: headers,
            resource: {print(String(data: $0, encoding: .utf8) ?? "get all artisan product failed")
            return $0},
            error: APIError.init,
            needsAuthorization: true
        )
      }

    static func fetchProductImage(with productId: Int, imageName: String) -> Request<Data, APIError> {
        var str = "Product/\(productId)/\(imageName)"
        str = str.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return Request(
            path: str,//"Product/10/download.jpg",//
            method: .get,
            resource: { $0 },
            error: APIError.init,
            needsAuthorization: false
        )
    }
    
    public static func getAllProducts(clusterId: Int) -> Request<[Product], APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getClusterProducts/\(clusterId)",
          method: .get,
          headers: headers,
          resource: {
//            print(String(data: $0, encoding: .utf8) ?? "get all products failed")
//            return $0
            
            if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
              if let obj = json["data"] as? [String: Any] {
                if let prodArray = obj["products"] as? [[String: Any]] {
                  if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                      if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                          return object
                      }
                  }
                }
              }
            }
            return []
          },
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getAllProducts(productCategoryId: Int) -> Request<[Product], APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getProductCategoryProducts/\(productCategoryId)",
          method: .get,
          headers: headers,
          resource: {
            if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
              if let obj = json["data"] as? [String: Any] {
                if let prodArray = obj["products"] as? [[String: Any]] {
                  if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                      if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                          return object
                      }
                  }
                }
              }
            }
            return []
          },
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getAllProducts(artisanId: Int) -> Request<[Product], APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getProductByArtisan/\(artisanId)",
          method: .get,
          headers: headers,
          resource: {
            if let json = try? JSONSerialization.jsonObject(with: $0, options: .allowFragments) as? [String: Any] {
              if let obj = json["data"] as? [String: Any] {
                if let prodArray = obj["products"] as? [[String: Any]] {
                  if let proddata = try? JSONSerialization.data(withJSONObject: prodArray, options: .fragmentsAllowed) {
                      if let object = try? JSONDecoder().decode([Product].self, from: proddata) {
                          return object
                      }
                  }
                }
              }
            }
            return []
          },
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func getProductUploadData() -> Request<Data, APIError> {
      //
      let headers: [String: String] = ["Authorization": "Bearer \(KeychainManager.standard.userAccessToken ?? "")"]
      return Request(
          path: "product/getProductUploadData",
          method: .get,
          headers: headers,
          resource: {print(String(data: $0, encoding: .utf8) ?? "get all artisan product failed")
          return $0},
          error: APIError.init,
          needsAuthorization: true
      )
    }
    
    public static func uploadProduct(json: [String: Any], imageData: [(String,Data)]) -> Request<Data, APIError> {
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
                path: "product/uploadProduct?productData=\(str)",
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
                path: "product/uploadProduct?productData=\(str)",
                method: .post,
                headers: headers,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artisan upload product failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }
    }
    
    public static func editProduct(json: [String: Any], imageData: [(String,Data)]) -> Request<Data, APIError> {
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
                path: "product/edit/product?productData=\(str)",
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
                path: "product/edit/product?productData=\(str)",
                method: .put,
                resource: {print(String(data: $0, encoding: .utf8) ?? "artisan edit product failed")
                  return $0},
                error: APIError.init,
                needsAuthorization: true
            )
        }
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
}
