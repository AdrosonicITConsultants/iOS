//
//  UIView+Extensions.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow() {
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 5
    }
    
    func heightForView(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 100
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 15)
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
    
    func addDashedBorder() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.darkGray.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.lineDashPattern = [5,5]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: 0),
                                CGPoint(x: self.frame.width, y: 0)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }
    func addBottomdBorder() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.darkGray.cgColor
        shapeLayer.lineWidth = 0.3
        shapeLayer.lineDashPattern = [1,0]
        
        let path = CGMutablePath()
        path.addLines(between: [CGPoint(x: 0, y: self.frame.height),
                                CGPoint(x: self.frame.width, y: self.frame.height)])
        shapeLayer.path = path
        layer.addSublayer(shapeLayer)
    }

    
    func showEnquiryInitiationView() {
        if self.isKind(of: UITableView.self) {
            let window = UIApplication.shared.windows.first!
            if let _ = window.viewWithTag(123) {
                print("do nothing")
            }else {
                let initiationView = Bundle.main.loadNibNamed("EnquiryInitiationView", owner:
                    self, options: nil)?.first as? UIView
                initiationView?.tag = 123
                window.addSubview(initiationView!)
                initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
                window.bringSubviewToFront(initiationView!)
            }
        }else {
            if let _ = self.viewWithTag(123) {
                print("do nothing")
            }else {
                let initiationView = Bundle.main.loadNibNamed("EnquiryInitiationView", owner:
                    self, options: nil)?.first as? UIView
                initiationView?.tag = 123
                self.addSubview(initiationView!)
                initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
                self.bringSubviewToFront(initiationView!)
            }
        }
    }
    
    func hideEnquiryInitiationView() {
        if let initialView = self.viewWithTag(123) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }else if let initialView = UIApplication.shared.windows.first!.viewWithTag(123) {
            UIApplication.shared.windows.first!.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showEnquiryExistsView(controller: UIViewController, prodName: String, enquiryCode: String, enquiryId: Int, prodId: Int) {
        if let _ = self.viewWithTag(124) {
            print("do nothing")
        }else if let _ = UIApplication.shared.windows.first!.viewWithTag(124) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("EnquiryExistsView", owner:
                self, options: nil)?.first as? EnquiryExistsView
            initiationView?.enquiryIdLabel.text = "With Enquiry Id \(enquiryCode)"
            initiationView?.productLabel.text = prodName
            initiationView?.productId = prodId
            initiationView?.enquiryId = enquiryId
            initiationView?.delegate = controller as? EnquiryExistsViewProtocol
            initiationView?.tag = 124
            if self.isKind(of: UITableView.self) {
                let window = UIApplication.shared.windows.first!
                window.addSubview(initiationView!)
                initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
                window.bringSubviewToFront(initiationView!)
            }else {
                self.addSubview(initiationView!)
                initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
                self.bringSubviewToFront(initiationView!)
            }
        }
    }
    
    func hideEnquiryExistsView() {
        if let initialView = self.viewWithTag(124) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }else if let initialView = UIApplication.shared.windows.first!.viewWithTag(124) {
            UIApplication.shared.windows.first!.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showEnquiryGenerateView(controller: UIViewController, enquiryId: Int, enquiryCode: String) {
        if let _ = self.viewWithTag(125) {
            print("do nothing")
        }else if let _ = UIApplication.shared.windows.first!.viewWithTag(125) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("EnquiryGeneratedView", owner:
                self, options: nil)?.first as? EnquiryGeneratedView
            initiationView?.enquiryCodeLabel.text = "Enquiry Id \(enquiryCode)"
            initiationView?.enquiryId = enquiryId
            initiationView?.delegate = controller as? EnquiryGeneratedViewProtocol
            initiationView?.tag = 125
            if self.isKind(of: UITableView.self) {
                let window = UIApplication.shared.windows.first!
                window.addSubview(initiationView!)
                initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
                window.bringSubviewToFront(initiationView!)
            }else {
                self.addSubview(initiationView!)
                initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
                self.bringSubviewToFront(initiationView!)
            }
        }
    }
    
    func hideEnquiryGenerateView() {
        if let initialView = self.viewWithTag(125) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }else if let initialView = UIApplication.shared.windows.first!.viewWithTag(125) {
            UIApplication.shared.windows.first!.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showAcceptMOQView(controller: UIViewController, getMOQs: GetMOQs) {
        if let _ = self.viewWithTag(126) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("MOQAcceptView", owner:
                self, options: nil)?.first as? MOQAcceptView
            initiationView?.brandClusterText.text = (getMOQs.brand ?? "") + " from " + getMOQs.clusterName!
            initiationView?.moqText.text = "\(getMOQs.moq!.moq) pcs"
            initiationView?.pricePerUnitText.text = "₹ " + getMOQs.moq!.ppu!
            initiationView?.ETADaysText.text = "\(EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getMOQs.moq!.deliveryTimeId)!.days) days"
            
            initiationView?.delegate = controller as? MOQAcceptViewProtocol
            initiationView?.tag = 126
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    func hideAcceptMOQView() {
        if let initialView = self.viewWithTag(126) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showAcceptedMOQView(controller: UIViewController, getMOQs: GetMOQs) {
        if let _ = self.viewWithTag(127) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("MOQAcceptedView", owner:
                self, options: nil)?.first as? MOQAcceptedView
            initiationView?.brandClusterText.text = (getMOQs.brand ?? "") + " from " + getMOQs.clusterName!
            initiationView?.moqText.text = "\(getMOQs.moq!.moq) pcs"
            initiationView?.pricePerUnitText.text = "₹ " + getMOQs.moq!.ppu!
            initiationView?.ETADaysText.text = "\(EnquiryMOQDeliveryTimes.getDeliveryType(TimeId: getMOQs.moq!.deliveryTimeId)!.days) days"
            
            initiationView?.delegate = controller as? MOQAcceptedViewProtocol
            initiationView?.tag = 127
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideAcceptedMOQView() {
        if let initialView = self.viewWithTag(127) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showPreviewPIView(controller: UIViewController, entityId: String, date: String, data: String, isPI: Bool) {
        if let _ = self.viewWithTag(128) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("PreviewPIView", owner:
                self, options: nil)?.first as? PreviewPIView
            
            if isPI == false{
               initiationView?.entityIdLabel.text = "Tax invoice for " + entityId
                initiationView?.sendButton.setTitle(" " + "Generate Tax Invoice", for: .normal)
            }
            initiationView?.dateLabel.text = "Date accepted " + date
            initiationView?.data = data
            initiationView?.delegate = controller as? PreviewPIViewProtocol
            initiationView?.tag = 128
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hidePreviewPIView() {
        if let initialView = self.viewWithTag(128) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showAcceptedPIView(controller: UIViewController, entityId: String, date: String, data: String, containsOld: Bool, raiseNewPI: Bool, isPI: Bool) {
        if let initiationView = self.viewWithTag(129) as? AcceptedPIView {
            print("do nothing")
            initiationView.entityIdLabel.text = "Pro forma invoice for " + entityId
            if isPI == false{
                initiationView.entityIdLabel.text = "Tax invoice for " + entityId
                initiationView.isTIDownload = true
            }
            initiationView.dateLabel.text = "Date accepted " + date
            initiationView.data = data
            /*if containsOld {
                initiationView.oldPIButton.isHidden = false
                initiationView.oldPIButton.setTitle("View Old PI".localized, for: .normal)
                initiationView.showOldPI = true
            }else if raiseNewPI {
                initiationView.oldPIButton.isHidden = false
                initiationView.oldPIButton.setTitle("Raise New PI".localized, for: .normal)
                initiationView.showRaisePI = true
            }else {
                initiationView.oldPIButton.isHidden = true
                initiationView.showOldPI = false
                initiationView.showRaisePI = false
            }*/
            initiationView.previewPI.loadHTMLString( data, baseURL: nil)
        }else {
            let initiationView = Bundle.main.loadNibNamed("AcceptedPIView", owner:
                self, options: nil)?.first as? AcceptedPIView
            initiationView?.entityIdLabel.text = "Pro forma invoice for ".localized + entityId
            if isPI == false{
                initiationView?.entityIdLabel.text = "Tax invoice for " + entityId
                initiationView?.isTIDownload = true
            }
            initiationView?.dateLabel.text = "Date accepted " + date
            initiationView?.data = data
            initiationView?.delegate = controller as? AcceptedPIViewProtocol
            initiationView?.tag = 129
            /*if containsOld {
                initiationView?.showOldPI = true
                initiationView?.oldPIButton.isHidden = false
                initiationView?.oldPIButton.setTitle("View Old PI".localized, for: .normal)
            }else if raiseNewPI {
                initiationView?.oldPIButton.isHidden = false
                initiationView?.oldPIButton.setTitle("Raise New PI".localized, for: .normal)
                initiationView?.showRaisePI = true
            }else {
                initiationView?.showOldPI = false
                initiationView?.showRaisePI = false
                initiationView?.oldPIButton.isHidden = true
            }*/
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideAcceptedPIView() {
        if let initialView = self.viewWithTag(129) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showTransactionReceiptView(controller: UIViewController, data: Data) {
        if let _ = self.viewWithTag(130) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("TransactionReceiptView", owner:
                self, options: nil)?.first as? TransactionReceiptView
            initiationView?.receiptImage.image = UIImage(data: data)
            initiationView?.delegate = controller as? TransactionReceiptViewProtocol
            initiationView?.tag = 130
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideTransactionReceiptView() {
        if let initialView = self.viewWithTag(130) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showOpenAttachmentView(controller: UIViewController, data: String) {
        if let _ = self.viewWithTag(131) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("OpenAttachmentView", owner:
                self, options: nil)?.first as? OpenAttachmentView
            initiationView?.attachmentURL = data
            initiationView?.delegate =  controller as? OpenAttachmentViewProtocol
            initiationView?.tag = 131
            let safeAreaTop: CGFloat

            if #available(iOS 11.0, *) {
                safeAreaTop = controller.view.safeAreaInsets.top
            } else {
                safeAreaTop = controller.topLayoutGuide.length
            }
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y:safeAreaTop, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideOpenAttachmentView() {
        if let initialView = self.viewWithTag(131) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showChatHeaderView(controller: UIViewController, chat: Chat) {
        if let _ = self.viewWithTag(132) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("ChatHeaderView", owner:
                self, options: nil)?.first as? ChatHeaderView
            initiationView?.buyerName.text = chat.buyerCompanyName
            initiationView?.enquiryNumber.text = chat.enquiryNumber
            initiationView?.orderStatus.text = chat.orderStatus
            if chat.changeRequestDone == 0{
                initiationView?.CRView.isHidden = true
            }
            initiationView?.imageButton.imageView?.layer.cornerRadius = 25
            if let tag = chat.buyerLogo, chat.buyerLogo != "" {
               let prodId = chat.buyerId
              if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                initiationView?.imageButton.setImage(downloadedImage, for: .normal)
              }else {
                  do {
                    let client = try SafeClient(wrapping: CraftExchangeImageClient())
                    let service = BrandLogoService.init(client: client)
                    service.fetch(forUser: chat.buyerId, img: chat.buyerLogo ?? "name.jpg").observeNext { (attachment) in
                      DispatchQueue.main.async {
                        let tag = chat.buyerLogo ?? "name.jpg"
                        let prodId = chat.buyerId
                        _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                        initiationView?.imageButton.setImage(UIImage.init(data: attachment), for: .normal)
                      }
                      }.dispose(in: controller.bag)
                  }catch {
                      print(error.localizedDescription)
                  }
              }
          }
            initiationView?.delegate =  controller as? ChatHeaderViewProtocol
            initiationView?.tag = 132
            self.addSubview(initiationView!)
            let safeAreaTop: CGFloat

            if #available(iOS 11.0, *) {
                safeAreaTop = controller.view.safeAreaInsets.top
            } else {
                safeAreaTop = controller.topLayoutGuide.length
            }
            initiationView?.frame = CGRect(x:0, y: safeAreaTop , width: self.frame.width, height: 120)
            
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func showChatHeaderDetailsView(controller: UIViewController, chat: Chat) {
        /*if let _ = self.viewWithTag(133) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("ChatHeaderDetailsView", owner:
                self, options: nil)?.first as? ChatHeaderDetailsView
            let date1 = Date().ttceFormatter(isoDate: chat.enquiryGeneratedOn!)
            
            initiationView?.enquiryStartedOn.text = "Date Started: ".localized + date1
            
            if chat.convertedToOrderDate != nil {
                let date2 = Date().ttceFormatter(isoDate: chat.convertedToOrderDate!)
                initiationView?.convertedToOrderOn.text = "Converted to order on: ".localized + date2
            }else{
                initiationView?.convertedToOrderOn.text = "Converted to order on: Not Converted".localized
            }
            
            let date3 = Date().ttceFormatter(isoDate: chat.lastUpdatedOn!)
            initiationView?.lastUpdatedOn.text = "Last updated on: ".localized + date3
            initiationView?.productType.text = chat.productTypeId ?? "Custom design".localized
            initiationView?.orderAmount.text = chat.orderAmount != nil ? "Order amount: ₹".localized + chat.orderAmount! : "Order amount: Not finalized".localized
            initiationView?.delegate =  controller as? ChatHeaderDetailsViewProtocol
            initiationView?.tag = 133
            self.addSubview(initiationView!)
            let safeAreaTop: CGFloat

            if #available(iOS 11.0, *) {
                safeAreaTop = controller.view.safeAreaInsets.top
            } else {
                safeAreaTop = controller.topLayoutGuide.length
            }
            initiationView?.frame = CGRect(x:0, y: safeAreaTop + 120, width: self.frame.width, height: 275)
            self.bringSubviewToFront(initiationView!)
            print(safeAreaTop)
        }*/
    }
    
    func hideChatHeaderDetailsView() {
        if let initialView = self.viewWithTag(133) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showOpenFAQView(controller: UIViewController, data: String) {
        if let _ = self.viewWithTag(134) {
            print("do nothing")
        } else {
            let initiationView = Bundle.main.loadNibNamed("OpenAttachmentView", owner:
                self, options: nil)?.first as? OpenAttachmentView
            initiationView?.attachmentURL = data
            initiationView?.delegate =  controller as? OpenAttachmentViewProtocol
            initiationView?.tag = 134
            self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x:0, y: 0, width: self.frame.width, height: self.frame.height)
            self.bringSubviewToFront(initiationView!)
        }
    }
    func hideOpenFAQView() {
        if let initialView = self.viewWithTag(134) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
    
    func showCloseOrderView(controller: UIViewController, enquiryCode: String?, confirmStatement: String?) {
        /*if let _ = self.viewWithTag(144) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("CloseOrderView", owner:
                self, options: nil)?.first as? CloseOrderView
            initiationView?.enquiryCode.text = enquiryCode ?? ""
            initiationView?.confirmStatement.text = confirmStatement ?? ""
            initiationView?.delegate =  controller as? CloseOrderViewProtocol
            initiationView?.tag = 144
           
            let effect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
           let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height)
            effectView.tag = 135
            self.addSubview(effectView)
             self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x: (self.frame.width/2) - 150, y: (self.frame.height/2) - 150, width: 300, height: 300)
            initiationView?.dropShadow()
            
            self.bringSubviewToFront(initiationView!)
        }*/
    }
    
    func hideCloseOrderView() {
        if let initialView = self.viewWithTag(144) {
           // self.effectView.removeFromSuperview()
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
        if let effectView = self.viewWithTag(135) {
            self.sendSubviewToBack(effectView)
                       effectView.removeFromSuperview()
        }
    }
    
    func showMarkAsDispatchedView(controller: UIViewController) {
        /*if let _ = self.viewWithTag(136) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("MarkAsDispatchedView", owner:
                self, options: nil)?.first as? MarkAsDispatchedView
           
            
            initiationView?.delegate =  controller as? MarkAsDispatchedViewProtocol
            initiationView?.tag = 136
            let effect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
            let effectView = UIVisualEffectView(effect: effect)
             effectView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height)
             effectView.tag = 137
              self.addSubview(effectView)
            self.addSubview(initiationView!)
           
            
            initiationView?.frame = CGRect(x: (self.frame.width/2) - 150, y: (self.frame.height/2) - 200, width: 300, height: 400)
            self.bringSubviewToFront(initiationView!)
           
        }*/
    }
    
    func hideMarkAsDispatchedView() {
        if let initialView = self.viewWithTag(136) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
        if let effectView = self.viewWithTag(137) {
            self.sendSubviewToBack(effectView)
                       effectView.removeFromSuperview()
        }
    }
    
    func showPartialRefundReceivedView(controller: UIViewController, enquiryCode: String?, confirmQuestion: String?) {
           /*if let _ = self.viewWithTag(138) {
               print("do nothing")
           }else {
               let initiationView = Bundle.main.loadNibNamed("PartialRefundReceivedView", owner:
                   self, options: nil)?.first as? PartialRefundReceivedView
               initiationView?.enquiryCode.text = enquiryCode ?? ""
            initiationView?.confirmQuestion.text = confirmQuestion ?? ""
               
               initiationView?.delegate =  controller as? PartialRefundReceivedViewProtocol
               initiationView?.tag = 138
              
               let effect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
              let effectView = UIVisualEffectView(effect: effect)
               effectView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height)
               effectView.tag = 139
               self.addSubview(effectView)
                self.addSubview(initiationView!)
               initiationView?.frame = CGRect(x: (self.frame.width/2) - 150, y: (self.frame.height/2) - 150, width: 300, height: 300)
               initiationView?.dropShadow()
               
               self.bringSubviewToFront(initiationView!)
              
           }*/
       }
    
       func hidePartialRefundReceivedView() {
           if let initialView = self.viewWithTag(138) {
              // self.effectView.removeFromSuperview()
               self.sendSubviewToBack(initialView)
               initialView.removeFromSuperview()
           }
           if let effectView = self.viewWithTag(139) {
               self.sendSubviewToBack(effectView)
                          effectView.removeFromSuperview()
           }
       }
    
    func showRatingInitaitionView(controller: UIViewController) {
          /*if let _ = self.viewWithTag(140) {
              print("do nothing")
          }else {
              let initiationView = Bundle.main.loadNibNamed("RatingInitaitionView", owner:
                  self, options: nil)?.first as? RatingInitaitionView
              initiationView?.delegate =  controller as? RatingInitaitionViewProtocol
              initiationView?.tag = 140
             
              let effect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
             let effectView = UIVisualEffectView(effect: effect)
              effectView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height)
              effectView.tag = 141
              self.addSubview(effectView)
               self.addSubview(initiationView!)
              initiationView?.frame = CGRect(x: (self.frame.width/2) - 150, y: (self.frame.height/2) - 200, width: 300, height: 400)
              initiationView?.dropShadow()
              
              self.bringSubviewToFront(initiationView!)
             
          }*/
      }
    
      func hideRatingInitaitionView() {
          if let initialView = self.viewWithTag(140) {
             // self.effectView.removeFromSuperview()
              self.sendSubviewToBack(initialView)
              initialView.removeFromSuperview()
          }
          if let effectView = self.viewWithTag(141) {
              self.sendSubviewToBack(effectView)
                         effectView.removeFromSuperview()
          }
      }
    
    func showBuyerReviewConfirmView(controller: UIViewController) {
        /*if let _ = self.viewWithTag(142) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("BuyerReviewConfirmView", owner:
                self, options: nil)?.first as? BuyerReviewConfirmView
            initiationView?.delegate =  controller as? BuyerReviewConfirmViewProtocol
            initiationView?.tag = 142
           
            let effect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
           let effectView = UIVisualEffectView(effect: effect)
            effectView.frame = CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:UIScreen.main.bounds.size.height)
            effectView.tag = 143
            self.addSubview(effectView)
             self.addSubview(initiationView!)
            initiationView?.frame = CGRect(x: (self.frame.width/2) - 150, y: (self.frame.height/2) - 160, width: 300, height: 320)
            initiationView?.dropShadow()
            
            self.bringSubviewToFront(initiationView!)
           
        }*/
    }
    
    func hideBuyerReviewConfirmView() {
        if let initialView = self.viewWithTag(142) {
           // self.effectView.removeFromSuperview()
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
        if let effectView = self.viewWithTag(143) {
            self.sendSubviewToBack(effectView)
                       effectView.removeFromSuperview()
        }
    }
    
    func showChatEscalationHeaderView(controller: UIViewController, chat: Chat) {
        if let _ = self.viewWithTag(150) {
            print("do nothing")
        }else {
            let initiationView = Bundle.main.loadNibNamed("ChatEscalationHeaderView", owner:
                self, options: nil)?.first as? ChatEscalationHeaderView
            initiationView?.enquiryNumber.text = chat.enquiryNumber
            initiationView?.delegate =  controller as? ChatEscalationHeaderViewProtocol
            initiationView?.tag = 150
            self.addSubview(initiationView!)
            let safeAreaTop: CGFloat

            if #available(iOS 11.0, *) {
                safeAreaTop = controller.view.safeAreaInsets.top
            } else {
                safeAreaTop = controller.topLayoutGuide.length
            }
            initiationView?.frame = CGRect(x:0, y: safeAreaTop , width: self.frame.width, height: 80)
            
            self.bringSubviewToFront(initiationView!)
        }
    }
    
    func hideChatEscalationHeaderDetailsView() {
        if let initialView = self.viewWithTag(150) {
            self.sendSubviewToBack(initialView)
            initialView.removeFromSuperview()
        }
    }
}
