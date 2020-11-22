//
//  UISegmentControl+Extensions.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation

extension UISegmentedControl {
    func setBlackControl() {
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let titleTextAttributes2 = [NSAttributedString.Key.foregroundColor: UIColor.black]
        self.setTitleTextAttributes(titleTextAttributes2, for: .selected)
    }
}
