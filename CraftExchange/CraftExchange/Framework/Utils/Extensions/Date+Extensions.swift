//
//  Date+Extensions.swift
//  CraftExchange
//
//  Created by Preety Singh on 15/08/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension Date {
    func ttceFormatter(isoDate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        
        let date = dateFormatter.date(from:isoDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.string(from: date ?? Date())
    }
}
