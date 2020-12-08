//
//  ChatEscalationController.swift
//  CraftExchange
//
//  Created by Syed Ashar Irfan on 09/11/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import MessageKit
import Reachability
import Realm
import RealmSwift
import InputBarAccessoryView
import ReactiveKit
import Bond
import MessageUI
import MobileCoreServices

struct EscalationMessage: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var id: Int
    var mediaName: String
    var pathName: String
    var resolved: Int
}

class ChatEscalationController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var chatObj: Chat!
    var messages: [EscalationConversation]?
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var id: [Int] = []
    var catId: [Int] = []
    var viewWillAppear: (() -> ())?
    var sendEscalationMessage: ((_ enquiryId: Int, _ catId: Int, _ escalationFrom: Int, _ escalationTo: Int, _ message: String) -> ())?
    var getAllEscalations: (() -> ())?
    var resolveEscalation: ((_ escalationId: Int) -> ())?
    
    var goToEnquiry: ((_ enquiryId: Int) -> ())?
    
    lazy var viewModel = SendMessageViewModel()
    let currentUser = Sender(senderId: "\(KeychainManager.standard.userID!)", displayName: KeychainManager.standard.username!)
    var otherUser:Sender?
    var messageObject = [MessageType]()
    var Bubble: TypingBubble?
    var user: User?
    var escalationBtn: UIButton {
        let btn = UIButton.init(type: .custom)
        btn.frame = CGRect.init(x: 0, y: 0, width: UIScreen().bounds.width, height: 60)
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 5
        btn.setTitle("Raise New Escalation", for: .normal)
        btn.addTarget(self, action: #selector(presentInputActionsheet), for: .touchUpInside)
        return btn
    }
    override var inputAccessoryView: UIView {
        return escalationBtn
    }
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.contentInset.top = 150
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.backgroundColor = #colorLiteral(red: 0.7199142575, green: 0, blue: 0, alpha: 1)
        
        showMessageTimestampOnSwipeLeft = true
        
        let image2View = UIImageView(frame: CGRect(x: 0, y: UIScreen.main.bounds.midY-167, width: 415, height: 254))
        image2View.image = #imageLiteral(resourceName: "ChatCx.pdf")
        messagesCollectionView.backgroundView =  UIImageView(image:#imageLiteral(resourceName: "ChatBg.pdf") )
        messagesCollectionView.backgroundView?.addSubview(image2View)
        additionalBottomInset = 50
        
        messageInputBar.inputTextView.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        messageInputBar.inputTextView.placeholder = "Type your new escalation here"
        //        messageInputBar.inputTextView.font = .systemFont(ofSize: 14, weight: .regular)
        messageInputBar.sendButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        messageInputBar.delegate = self
        messages = []
        
        definesPresentationContext = false
        self.setupSideMenu(true)
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
    }
    
    @objc private func presentInputActionsheet(){
        let alert = UIAlertController.init(title: "", message: "Choose", preferredStyle: .actionSheet)
        
        if let escalationCategories = realm?.objects(EscalationCategory.self).filter("%K IN %@","id", catId) {
            
            for category in escalationCategories {
                let change = UIAlertAction.init(title: category.category, style: .default) { (action) in
                    self.sendInputActionsheet(mediaName: category.category ?? "Others", mediaId: category.id)
                }
                alert.addAction(change)
            }
        }
        
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    let textView = UITextView(frame: CGRect.zero)
    func sendInputActionsheet(mediaName: String, mediaId: Int){
        let alertController = UIAlertController(title: "\(mediaName) \n\n\n\n\n", message: nil, preferredStyle: .alert)

        let cancelAction = UIAlertAction.init(title: "Cancel", style: .default) { (action) in
            alertController.view.removeObserver(self, forKeyPath: "bounds")
            self.textView.text = ""
        }
        alertController.addAction(cancelAction)

        let saveAction = UIAlertAction(title: "Raise Escalation".localized, style: .default) { (action) in
            if let enteredText = self.textView.text, enteredText.isNotBlank {
                alertController.view.removeObserver(self, forKeyPath: "bounds")
                self.confirmAction("Are you sure?".localized, "you want to send as " + mediaName + "?", confirmedCallback: { (action) in
                    self.sendEscalationMessage?(self.chatObj.enquiryId, mediaId, KeychainManager.standard.userID!, self.chatObj.buyerId, enteredText)
                    self.textView.text = ""
                }) { (action) in
                    self.textView.text = ""
                }
            }else {
                self.alert("Error","Please enter escaltion details.")
            }
        }
        alertController.addAction(saveAction)

        alertController.view.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        textView.backgroundColor = UIColor.white
        textView.textContainerInset = UIEdgeInsets.init(top: 8, left: 5, bottom: 8, right: 5)
        textView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))

        alertController.view.addSubview(self.textView)

        self.present(alertController, animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds"{
            if let rect = (change?[NSKeyValueChangeKey.newKey] as? NSValue)?.cgRectValue {
                let margin: CGFloat = 8
                let xPos = rect.origin.x + margin
                let yPos = rect.origin.y + 54
                let width = rect.width - 2 * margin
                let height: CGFloat = 90

                textView.frame = CGRect.init(x: xPos, y: yPos, width: width, height: height)
            }
        }
    }
    
    @objc func tapDone(sender: Any) {
//       self.view.endEditing(true)
        textView.resignFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
        self.tabBarController!.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController!.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.showChatEscalationHeaderView(controller: self, chat: chatObj)
    }
    
    func endRefresh() {
        
        messages = realm?.objects(EscalationConversation.self).filter("%K IN %@","enquiryId", id).sorted(byKeyPath: "enquiryId", ascending: true).compactMap({$0})
        otherUser = Sender(senderId: "\(chatObj.buyerId)", displayName: chatObj.buyerCompanyName!)
        
        if messages != []{
            for obj in messages! {
                if self.chatObj?.buyerId != obj.escalationFrom {
                    showMessage(obj: obj, user: currentUser)
                } else {
                    showMessage(obj: obj, user: otherUser!)
                }
            }
        }
        
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        self.scrollsToBottomOnKeyboardBeginsEditing = true
        self.scrollsToLastItemOnKeyboardBeginsEditing = true
    }
    
    
    func showMessage(obj: EscalationConversation, user: SenderType){
        
        let fullString = NSMutableAttributedString(string: "")
        let imageAttachment = NSTextAttachment()
        
        let titleParagraphStyle = NSMutableParagraphStyle()
        titleParagraphStyle.alignment = .justified
        
        if Int(user.senderId) != chatObj.buyerId {
            fullString.append(NSAttributedString(string: "  " ))
            fullString.append(NSAttributedString(string:  obj.text ?? "", attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor.black
            ]))
            
            if obj.resolved == 0 {
                
                fullString.append(NSAttributedString(string:  "\n\n Mark as resolved  " , attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1),
                    .paragraphStyle: titleParagraphStyle
                ]))
                
                imageAttachment.image = UIImage(systemName: "checkmark.circle")!.withTintColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
                let imageString = NSAttributedString(attachment: imageAttachment)
                fullString.append(imageString)
                
                messageObject.append(EscalationMessage(sender: user,
                                                       messageId: String(obj.id),
                                                       sentDate: Date().ttceISODate(isoDate: obj.modifiedOn!),
                                                       kind: .attributedText(fullString),
                                                       id: obj.id, mediaName: "", pathName: "",
                                                       resolved: obj.resolved))
            } else {
                
                fullString.append(NSAttributedString(string:  "\n\n Resolved  " , attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .foregroundColor: UIColor().CEGreen(),
                    .paragraphStyle: titleParagraphStyle
                ]))
                
                imageAttachment.image = UIImage(systemName: "checkmark.circle")!.withTintColor(UIColor().CEGreen())
                let imageString = NSAttributedString(attachment: imageAttachment)
                fullString.append(imageString)
                
                messageObject.append(EscalationMessage(sender: user,
                                                       messageId: String(obj.id),
                                                       sentDate: Date().ttceISODate(isoDate: obj.modifiedOn!),
                                                       kind: .attributedText(fullString),
                                                       id: obj.id, mediaName: "", pathName: "",
                                                       resolved: obj.resolved))
            }
            
        } else {
            
            fullString.append(NSAttributedString(string: "  " ))
            fullString.append(NSAttributedString(string:  obj.text ?? "", attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                .foregroundColor: UIColor.white
            ]))
            
            if obj.resolved == 0 {
                
                fullString.append(NSAttributedString(string:  "\n\n Waiting for response from User  " , attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .foregroundColor: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                ]))
                
                imageAttachment.image = UIImage(systemName: "checkmark.circle")!.withTintColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1))
                let imageString = NSAttributedString(attachment: imageAttachment)
                fullString.append(imageString)
                
                messageObject.append(EscalationMessage(sender: user,
                                                       messageId: String(obj.id),
                                                       sentDate: Date().ttceISODate(isoDate: obj.modifiedOn!),
                                                       kind: .attributedText(fullString),
                                                       id: obj.id, mediaName: "", pathName: "",
                                                       resolved: obj.resolved))
            } else {
                
                fullString.append(NSAttributedString(string:  "\n\n Resolved  " , attributes: [
                    .font: UIFont.systemFont(ofSize: 15, weight: .medium),
                    .foregroundColor: UIColor().CEGreen()
                ]))
                
                imageAttachment.image = UIImage(systemName: "checkmark.circle")!.withTintColor(UIColor().CEGreen())
                let imageString = NSAttributedString(attachment: imageAttachment)
                fullString.append(imageString)
                
                messageObject.append(EscalationMessage(sender: user,
                                                       messageId: String(obj.id),
                                                       sentDate: Date().ttceISODate(isoDate: obj.modifiedOn!),
                                                       kind: .attributedText(fullString),
                                                       id: obj.id, mediaName: "", pathName: "",
                                                       resolved: obj.resolved))
            }
        }
        
    }
    
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1): #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageObject[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messageObject.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if messageObject[indexPath.section].sender.senderId == "\(KeychainManager.standard.userID!)"{
            avatarView.initials = "Me"
            user = User.getUser(userId: KeychainManager.standard.userID!)
            
            if let tag = user?.buyerCompanyDetails.first?.logo, user?.buyerCompanyDetails.first?.logo != "" {
                let prodId = user!.entityID
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    avatarView.image = downloadedImage
                } else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = chatBrandLogoService.init(client: client, chatObj: chatObj)
                        service.fetch().observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = self.user?.buyerCompanyDetails.first?.logo ?? "name.jpg"
                                let prodId = self.user!.entityID
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                avatarView.image = UIImage.init(data: attachment)
                            }
                        }.dispose(in: self.bag)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            avatarView.initials = "They"
            
            if let tag = chatObj.buyerLogo, chatObj.buyerLogo != "" {
                let prodId = chatObj.buyerId
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    avatarView.image = downloadedImage
                } else {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeImageClient())
                        let service = chatBrandLogoService.init(client: client, chatObj: chatObj)
                        service.fetch().observeNext { (attachment) in
                            DispatchQueue.main.async {
                                let tag = self.chatObj.buyerLogo ?? "name.jpg"
                                let prodId = self.chatObj.buyerId
                                _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                avatarView.image = UIImage.init(data: attachment)
                            }
                        }.dispose(in: self.bag)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        //        viewModel.enquiryId.value = self.chatObj.enquiryId
        //        viewModel.messageTo.value = self.chatObj.buyerId
        viewModel.messageFrom.value = KeychainManager.standard.userID!
        viewModel.messageString.value = text
        viewModel.mediaType.value = 1
        
        //clearing input field
        inputBar.inputTextView.text = ""
        self.presentInputActionsheet()
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
}

extension ChatEscalationController: MessageCellDelegate, ChatEscalationHeaderViewProtocol  {
    
    func escalationButtonSelected2() {
        navigationController?.popViewController(animated: true)
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        
        if self.chatObj?.buyerId != Int(message.sender.senderId) && message.resolved != 1 {
            let alert = UIAlertController.init(title: "Are you sure", message: "you want to mark it as resolved " + "?", preferredStyle: .actionSheet)
            
            let save = UIAlertAction.init(title: "Yes", style: .default) { (action) in
                self.resolveEscalation?(message.id)
            }
            alert.addAction(save)
            
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
