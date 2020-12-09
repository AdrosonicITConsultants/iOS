//
//  ProductCatalogService.swift
//  CraftExchange
//
//  Created by Preety Singh on 21/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import ReactiveKit
import RealmSwift
import SwiftKeychainWrapper

class ProductCatalogService: BaseService<Data> {
    
    required init() {
        super.init()
    }
    
    func fetchAllArtisanProduct() -> SafeSignal<Data> {
        return Product.getAllArtisanProduct().response(using: client).debug()
    }
    
    func fetchAllFilteredArtisan() -> SafeSignal<Data> {
        return User.getFilteredArtisans().response(using: client).debug()
    }
    
    func fetchAllProducts(clusterId: Int) -> SafeSignal<[Product]> {
        return Product.getAllProducts(clusterId: clusterId).response(using: client).debug()
    }
    
    func fetchAllProducts(categoryId: Int) -> SafeSignal<[Product]> {
        return Product.getAllProducts(productCategoryId: categoryId).response(using: client).debug()
    }
    
    func fetchAllProducts(artisanId: Int) -> SafeSignal<[Product]> {
        return Product.getAllProducts(artisanId: artisanId).response(using: client).debug()
    }
    
    func addProductToWishlist(prodId: Int) -> SafeSignal<Data> {
        return Product.addProductToWishlist(withId: prodId).response(using: client).debug()
    }
    
    func removeProductFromWishlist(prodId: Int) -> SafeSignal<Data> {
        return Product.deleteProductFromWishlist(withId: prodId).response(using: client).debug()
    }
    
    func searchArtisan(page:Int, suggestion: String, suggestionType: Int, madeWithAntaran: Int) -> SafeSignal<Data> {
        return Product.searchArtisanProduct(page: page, searchString: suggestion, suggectionType: suggestionType, madeWithAntaran: madeWithAntaran).response(using: client).debug()
    }
    
    func searchBuyerProducts(page:Int, suggestion: String, suggestionType: Int, madeWithAntaran: Int) -> SafeSignal<Data> {
        return Product.searchBuyerProduct(page: page, searchString: suggestion, suggectionType: suggestionType, madeWithAntaran: madeWithAntaran).response(using: client).debug()
    }
    
    func getProductDetails(prodId: Int) -> SafeSignal<Data> {
        return Product.getProductDetails(prodId: prodId).response(using: client).debug()
    }
    
    func checkIfEnquiryExists(prodId: Int, isCustom: Bool) -> SafeSignal<Data> {
        return Enquiry.checkIfEnquiryExists(for: prodId, isCustom: isCustom).response(using: client).debug()
    }
    
    func generateEnquiry(prodId: Int, isCustom: Bool) -> SafeSignal<Data> {
        return Enquiry.generateEnquiry(productId: prodId, isCustom: isCustom).response(using: client).debug()
    }
    
    func getHistoryProductDetails(prodId: Int) -> SafeSignal<Data> {
        return Product.getHistoryProductDetails(prodId: prodId).response(using: client).debug()
    }
}
