//
//  Searchable.swift
//  Knowledgemill
//
//  Created by Heramb Joshi on 4/30/20.
//  Copyright © 2020 ADROSONIC. All rights reserved.
//

import Foundation
import UIKit

public protocol Searchable {
  var searchController: UISearchController? { get set }
}

public extension Searchable where Self: UIViewController, Self: UISearchBarDelegate {
  
    func setup(with searchController: UISearchController?, and tableView: UITableView? = nil) {
    searchController?.obscuresBackgroundDuringPresentation = true
    searchController?.searchBar.delegate = self
    searchController?.searchBar.sizeToFit()
    tableView?.tableHeaderView = searchController?.searchBar
    searchController?.searchBar.isTranslucent = false
    enableSearch()
    UISearchBar.appearance().backgroundImage = UIImage()
  }
  
  func enableSearch() {
    searchController?.searchBar.isUserInteractionEnabled = true
    searchController?.searchBar.barTintColor = .lightGray
    searchController?.searchBar.backgroundColor = .lightGray
    searchController?.searchBar.tintColor = UIColor().menuSelectorBlue()
    if let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField,
      let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
      glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
      glassIconView.tintColor = UIColor().menuSelectorBlue()
      textFieldInsideSearchBar.backgroundColor = UIColor.white
    }
  }
  
  func disableSearch() {
    let cancelButtonAttributes: NSDictionary = [convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): UIColor().menuSelectorBlue()]
    UIBarButtonItem.appearance().setTitleTextAttributes(convertToOptionalNSAttributedStringKeyDictionary(cancelButtonAttributes as? [String : AnyObject]), for: UIControl.State())
    searchController?.searchBar.isUserInteractionEnabled = false
    searchController?.searchBar.barTintColor = .lightGray
    searchController?.searchBar.backgroundColor = .lightGray
    searchController?.searchBar.tintColor = UIColor().menuSelectorBlue()
    if let textFieldInsideSearchBar = searchController?.searchBar.value(forKey: "searchField") as? UITextField,
      let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
      glassIconView.image = glassIconView.image?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
      glassIconView.tintColor = UIColor.darkGray
        textFieldInsideSearchBar.backgroundColor = .lightGray
    }
  }
  
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

