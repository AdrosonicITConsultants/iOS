//
//  ImageViewRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 17/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

@objc protocol ProdDetailWishlistProtocol {
    @objc optional func addToWishlist(prodId: Int)
    @objc optional func deleteProdWishlist(prodId: Int)
}

class ImageViewRowView: Cell<String>, CellType {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var productCodeLbl: UILabel!
    @IBOutlet weak var productCodeValue: UILabel!
    @IBOutlet weak var wishlistBtn: UIButton!
    var delegate: ProdDetailWishlistProtocol?
    
    public override func setup() {
        super.setup()
        wishlistBtn.addTarget(self, action: #selector(wishlistSelected(_:)), for: .touchUpInside)
    }

    public override func update() {
        super.update()
    }
    
    @objc @IBAction func wishlistSelected(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if appDelegate?.wishlistIds?.contains(where: { (obj) -> Bool in
            obj == wishlistBtn.tag
        }) ?? false {
            wishlistBtn.setImage(UIImage.init(named: "tab-wishlist"), for: .normal)
            self.delegate?.deleteProdWishlist?(prodId: wishlistBtn.tag)
        }else {
            wishlistBtn.setImage(UIImage.init(named: "red heart"), for: .normal)
            self.delegate?.addToWishlist?(prodId: wishlistBtn.tag)
        }
    }
}

// The custom Row also has the cell: CustomCell and its correspond value
final class ImageViewRow: Row<ImageViewRowView>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<ImageViewRowView>(nibName: "ImageViewRow")
    }
}
