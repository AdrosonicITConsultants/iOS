//
//  ChatCell.swift
//  CraftExchange
//
//  Created by Kalyan on 13/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit

class ChatCell: UITableViewCell {
    
    @IBOutlet weak var logo: RoundedButton!
    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var enquiryCode: UILabel!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var lastUpdatedOn: UILabel!
    @IBOutlet weak var isEscalationPresent: UIButton!
    @IBOutlet weak var unreadMessages: RoundedButton!
    

    func configure(_ chatObj: Chat) {
        companyName.text = chatObj.buyerCompanyName
        enquiryCode.text = chatObj.enquiryNumber
        logo.imageView?.layer.cornerRadius = 25
         
        if chatObj.escalation > 0 {
    isEscalationPresent.isHidden = false
        }else{
         isEscalationPresent.isHidden = true
        }
        
        if chatObj.unreadMessage > 0 {
            unreadMessages.isHidden = false
        }else{
            unreadMessages.isHidden = true
        }
        
        if let tag = chatObj.buyerLogo, chatObj.buyerLogo != "" {
            let prodId = chatObj.buyerId
                       if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        logo.setImage(downloadedImage, for: .normal)
                       }else {
                           do {
                               let client = try SafeClient(wrapping: CraftExchangeImageClient())
                               let service = chatBrandLogoService.init(client: client, chatObj: chatObj)
                               service.fetch().observeNext { (attachment) in
                                   DispatchQueue.main.async {
                                    let tag = chatObj.buyerLogo ?? "name.jpg"
                                       let prodId = chatObj.buyerId
                                       _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    self.logo.setImage(UIImage.init(data: attachment), for: .normal)
                                   }
                               }.dispose(in: self.bag)
                           }catch {
                               print(error.localizedDescription)
                           }
                       }
                   }
        
        
        
    unreadMessages.setTitle("\(chatObj.unreadMessage)" , for: .normal)
        
    }
}
