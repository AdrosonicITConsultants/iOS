//
//  CollectionViewRow.swift
//  CraftExchange
//
//  Created by Preety Singh on 30/07/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Eureka

class CollectionViewCellRow: Cell<String>, CellType {
    
    @IBOutlet var collectionView: UICollectionView!
    var collectionDelegate: UIViewController!
    public override func setup() {
        super.setup()
    }
    
    public override func update() {
        super.update()
        //backgroundColor = (row.value ?? false) ? .white : .black
        collectionView.dataSource = collectionDelegate as? UICollectionViewDataSource
        collectionView.delegate = collectionDelegate as? UICollectionViewDelegate
    }
    
}

// The custom Row also has the cell: CustomCell and its correspond value
final class CollectionViewRow: Row<CollectionViewCellRow>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
        // We set the cellProvider to load the .xib corresponding to our cell
        cellProvider = CellProvider<CollectionViewCellRow>(nibName: "CollectionViewRow")
    }
}

