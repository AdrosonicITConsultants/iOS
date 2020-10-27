//
//  Strings+Extensions.swift
//  CraftExchange
//
//  Created by Preety Singh on 27/05/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension String {
  var boolValue: Bool {
      return self == "true"
  }
  
  var isNotBlank: Bool {
    let str = self.trimmingCharacters(in: .whitespaces)
    return !str.isEmpty
  }
  
  var isValidEmailAddress: Bool {
      let emailRegEx = "['´’`‘A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
      let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
      return emailTest.evaluate(with: self)
  }
  
  var isValidPhoneNumber: Bool {
      let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
      let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
      return phoneTest.evaluate(with: self)
  }
    
  var isValidNumber: Bool {
      let numberRegex = "^[0-9]{1,10}$"
      let numberTest = NSPredicate(format: "SELF MATCHES %@", numberRegex)
      return numberTest.evaluate(with: self)
  }
  
  var isValidPincode: Bool {
    let pincodeRegEx = "^[1-9][0-9]{5}$"
    let pincodeTest = NSPredicate(format: "SELF MATCHES %@", pincodeRegEx)
    let result = pincodeTest.evaluate(with: self)
    return result
  }
  
  var isValidPassword: Bool {
    let passwordRegEx = "^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z]).{8,20}$"
    let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
    let result = passwordTest.evaluate(with: self)
    return result
  }
  
  var isValidUrl: Bool {
      let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
      let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
      let result = urlTest.evaluate(with: self)
      return result
  }
  
  var isValidPAN: Bool {
      let panRegEx = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
      let panTest = NSPredicate(format:"SELF MATCHES %@", panRegEx)
      let result = panTest.evaluate(with: self)
      return result
  }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
