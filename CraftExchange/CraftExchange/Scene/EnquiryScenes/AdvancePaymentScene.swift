//
//  AdvancePaymentScene.swift
//  CraftExchange
//
//  Created by Kalyan on 06/10/20.
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
    
    func createPaymentScene(enquiryId: Int)-> UIViewController {
        let vc = PaymentUploadController.init(style: .plain)
        
        vc.uploadReciept = {
            if vc.viewModel.imageData.value != nil {
                self.uploadReceipt(enquiryId: enquiryId, type: 1, paidAmount: Int(vc.viewModel.paidAmount.value!)!, percentage: Int(vc.viewModel.percentage.value!)!, pid: Int(vc.viewModel.pid.value!)!, totalAmount: Int(vc.viewModel.totalAmount.value!)!, imageData: vc.viewModel.imageData.value, filename: vc.viewModel.fileName.value).bind(to: vc, context: .global(qos: .background)) {_,responseData in
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                        if json["valid"] as? Bool == true {
                            DispatchQueue.main.async {
                                
                                vc.form.rowBy(tag: "uploadReceipt")?.hidden = true
                                vc.form.rowBy(tag: "uploadReceipt")?.evaluateHidden()
                                vc.form.rowBy(tag: "uploadsuccess")?.hidden = false
                                vc.form.rowBy(tag: "uploadsuccess")?.evaluateHidden()
                                vc.form.allSections.first?.reload(with: .none)
                                vc.imageReciept?()
                                let viewControllers = vc.navigationController!.viewControllers
                                vc.navigationController!.viewControllers.remove(at: viewControllers.count - 2)
                                vc.hideLoading()
                            }
                        }
                    }
                }.dispose(in: vc.bag)
            }
            else {
                vc.alert("Please upload image")
                vc.hideLoading()
            }
        }
        
        vc.imageReciept = {
            self.downloadAndViewReceipt(vc: vc, enquiryId: enquiryId)
        }
        
        return vc
    }
    
    func downloadAndViewReceipt(vc: UIViewController, enquiryId: Int) {
        self.ImgReceit(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
            
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
                
                if let dataDict = json["data"] as? Dictionary<String,Any>
                {
                    if let recieptdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                        
                        if  let object = try? JSONDecoder().decode(PaymentArtist.self, from: recieptdata) {
                            DispatchQueue.main.async {
                                print("hey:\(object)")
                                if let controller = vc as? PaymentUploadController {
                                    controller.receipt = object
                                }
                                let name = object.label
                                let paymentID = object.paymentId
                            
                                let url = URL(string: "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net/AdvancedPayment/\(paymentID)/" + name!)
                                URLSession.shared.dataTask(with: url!) { data, response, error in
                                    DispatchQueue.main.async {
                                        if error == nil {
                                            if let finalData = data {
                                                if let controller = vc as? PaymentUploadController {
                                                    controller.data = finalData
                                                }else if let controller = vc as? TransactionListController {
                                                    controller.hideLoading()
                                                    controller.view.showTransactionReceiptView(controller: controller, data: finalData)
                                                }else if let controller = vc as? PaymentArtistController{
                                                    //controller.hideLoading()
                                                    let row = controller.form.rowBy(tag: "PaymentArtist-1") as? ArtistReceitImgRow
                                                                        row?.cell.ImageReceit.image = UIImage(data: finalData)
                                                   //  controller.hideLoading()
                                                  
                                                }
                                            }
                                        }
                                    }
                                }.resume()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func advancePaymentStatus(vc: UIViewController, enquiryId: Int) {
        self.getAdvancePaymentStatus(enquiryId: enquiryId).bind(to: vc, context: .global(qos: .background)) { (_,responseData) in
        
        if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? Dictionary<String,Any> {
            
            if let dataDict = json["data"] as? Dictionary<String,Any>
            {
                if let paymentdata = try? JSONSerialization.data(withJSONObject: dataDict, options: .fragmentsAllowed) {
                    
                    if  let object = try? JSONDecoder().decode(PaymentStatus.self, from: paymentdata) {
                                DispatchQueue.main.async {
                                    print("hey:\(object)")
                                    if let controller = vc as? PaymentArtistController{
                                       // controller.hideLoading()
                                        let row = controller.form.rowBy(tag: "PaymentArtist-1") as? ArtistReceitImgRow
                                        row?.cell.AmountLabel.text = "Amount to be Paid as per PI: \(object.paidAmount)"
                                       
                                      
                                    }

                                }

                            }

                        }

                    }
            }
            
        }.dispose(in: vc.bag)
    }
    
    func validateadvancePaymentFunc(vc: UIViewController,enquiryObj: Enquiry, enquiryId: Int, status: Int) {
        self.validateAdvancePayment(enquiryId: enquiryId, status: status).bind(to: vc, context: .global(qos: .background)) {_,responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    DispatchQueue.main.async {
                        let client = try! SafeClient(wrapping: CraftExchangeClient())
                        let vc1 = EnquiryDetailsService(client: client).createEnquiryDetailScene(forEnquiry: enquiryObj, enquiryId: enquiryId) as! BuyerEnquiryDetailsController
                        vc1.modalPresentationStyle = .fullScreen
                        vc.hideLoading()
                        vc1.viewWillAppear?()
                        vc.popBack(toControllerType: BuyerEnquiryDetailsController.self)

                        
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
    func changeInnerStageFunc(vc: UIViewController, enquiryId: Int, stageId: Int, innerStageId: Int) {
        self.changeInnerStage(enquiryId: enquiryId, stageId: stageId, innerStageId: innerStageId).bind(to: vc, context: .global(qos: .background)) {_,responseData in
            if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: Any] {
                if json["valid"] as? Bool == true {
                    DispatchQueue.main.async {
                        vc.hideLoading()
                        if let controller = vc as? BuyerEnquiryDetailsController {
                            controller.viewWillAppear?()
                        }
                    }
                }
            }
        }.dispose(in: vc.bag)
    }
    
}
