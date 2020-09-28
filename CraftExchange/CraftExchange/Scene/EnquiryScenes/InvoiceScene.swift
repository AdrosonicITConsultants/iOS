//
//  InvoiceScene.swift
//  CraftExchange
//
//  Created by Kiran Songire on 23/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Bond
import Foundation
import JGProgressHUD
import ReactiveKit
import Realm
import RealmSwift
import UIKit

extension EnquiryDetailsService {
    func piCreate(enquiryId: Int) -> UIViewController {
        let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "InvoiceController") as! InvoiceController
        
        
        vc.viewModel.savePI = {
            print("\(vc.viewModel.ppu.value),\(vc.viewModel.cgst.value),\(vc.viewModel.expectedDateOfDelivery.value),\(vc.viewModel.hsn.value),\(vc.viewModel.quantity.value)\(vc.viewModel.sgst.value)")
            self.savePI(enquiryId: enquiryId, cgst: Int(vc.viewModel.cgst.value!)!, expectedDateOfDelivery: String(vc.viewModel.expectedDateOfDelivery.value!), hsn: Int(vc.viewModel.hsn.value!)!, ppu: Int(vc.viewModel.ppu.value!)! , quantity: Int(vc.viewModel.quantity.value!)!, sgst: Int(vc.viewModel.sgst.value!)!).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                    if json["valid"] as? Bool == true {
                        DispatchQueue.main.async {
                            vc.saveInvoice = 1
                            print("saveInvoice PI")
//                            let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
//                            let vc1 = storyboard.instantiateViewController(withIdentifier: "InvoicePreviewController") as! InvoicePreviewController
//                            print("PreviewPI WORKING")
//                            vc1.modalPresentationStyle = .fullScreen
//                            vc.navigationController?.pushViewController(vc1, animated: true)
                            print("createSendInvoiceBtnSelected WORKING")
                            
                        }
                    }
                }
            }.dispose(in: vc.bag)
            
        }
        return vc
    }
}
extension  EnquiryDetailsService {
   func piSend(enquiryId: Int) -> UIViewController {
    let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
           let vc = storyboard.instantiateViewController(withIdentifier: "InvoicePreviewController") as! InvoicePreviewController
    vc.viewModel.sendPI = {
               print("SEENND PIII \(vc.viewModel.ppu.value),\(vc.viewModel.cgst.value),\(vc.viewModel.expectedDateOfDelivery.value),\(vc.viewModel.hsn.value),\(vc.viewModel.quantity.value)\(vc.viewModel.sgst.value)")
               self.sendPI(enquiryId: enquiryId, cgst: Int(vc.viewModel.cgst.value!)!, expectedDateOfDelivery: String(vc.viewModel.expectedDateOfDelivery.value!), hsn: Int(vc.viewModel.hsn.value!)!, ppu: Int(vc.viewModel.ppu.value!)! , quantity: Int(vc.viewModel.quantity.value!)!, sgst: Int(vc.viewModel.sgst.value!)!).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                   if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                       if json["valid"] as? Bool == true {
                           DispatchQueue.main.async {
                               vc.sendInvoice = 1
                               print("sendInvoice PI")
//                               let storyboard = UIStoryboard(name: "Invoice", bundle: nil)
//                               let vc1 = storyboard.instantiateViewController(withIdentifier: "InvoicePreviewController") as! InvoicePreviewController
//                               print("PreviewPI WORKING")
//                               vc1.modalPresentationStyle = .fullScreen
//                               vc.navigationController?.pushViewController(vc1, animated: true)
//                               print("createSendInvoiceBtnSelected WORKING")
                               
                           }
                       }
                   }
               }.dispose(in: vc.bag)
               
           }
           return vc
       }
}

