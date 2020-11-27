//
//  ChatDetailsController.swift
//  CraftExchange
//
//  Created by Kalyan on 15/10/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import UIKit
import AVKit
import MessageKit
import Reachability
import Realm
import RealmSwift
import ReactiveKit
import Bond
import MessageUI
import MobileCoreServices

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var id: Int
    var mediaName: String
    var pathName: String
    var resolved: Int
}

class SendMessageViewModel {
    var enquiryId = Observable<Int?>(nil)
    var messageFrom = Observable<Int?>(nil)
    var messageTo =  Observable<Int?>(nil)
    var messageString = Observable<String?>(nil)
    var mediaType = Observable<Int?>(nil)
    var mediaData = Observable<Data?>(nil)
    var fileName = Observable<String?>(nil)
}


class ChatDetailsController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var messages: [Conversation]?
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var id: [Int] = []
    var viewWillAppear: (() -> ())?
    let currentUser = Sender(senderId: "1", displayName: "Buyer")
    var otherUser = Sender(senderId: "0", displayName: "Artisan")
    var messageObject = [MessageType]()
    var user: User?
    var enquiryId: Int?
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.contentInset.top = 75
        self.inputAccessoryView?.isHidden = true
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        showMessageTimestampOnSwipeLeft = true
        
        let image2View = UIImageView(frame: CGRect(x: 0, y: UIScreen.main.bounds.midY-167, width: 415, height: 254))
        image2View.image = UIImage.init(named: "ChatCx")
        messagesCollectionView.backgroundView =  UIImageView(image: UIImage.init(named: "ChatBg"))
        messagesCollectionView.backgroundView?.addSubview(image2View)
        additionalBottomInset = 50
        messages = []
        
        definesPresentationContext = false
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
        let rightButtonItem = UIBarButtonItem.init(title: "Escalations", style: .plain, target: self, action: #selector(viewEscalations))
        self.navigationItem.rightBarButtonItem = rightButtonItem
    }
    
    @objc func viewEscalations() {
        do {
            let client = try SafeClient(wrapping: CraftExchangeClient())
            let vc = ChatDetailsService(client: client).createEscalationScene(enquiryId: self.enquiryId ?? 0)
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.pushViewController(vc, animated: true)
            
        }catch {
            print(error.localizedDescription)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
    }
    
    func endRefresh() {
        if self.reachabilityManager?.connection == .unavailable {
            messages = realm?.objects(Conversation.self).filter("%K == %@","enquiryId", self.enquiryId ?? 0 ).sorted(byKeyPath: "entityID", ascending: true).compactMap({$0})
        }else{
            messages = realm?.objects(Conversation.self).filter("%K IN %@","entityID", id ).sorted(byKeyPath: "entityID", ascending: true).compactMap({$0})
        }
        
        if messages != []{
            for obj in messages! {
                if obj.isBuyer == 1{
                    showMessage(obj: obj, user: currentUser)
                }else{
                    showMessage(obj: obj, user: otherUser)
                }
            }
            let safeAreaTop: CGFloat

            if #available(iOS 11.0, *) {
                safeAreaTop = self.view.safeAreaInsets.top
            } else {
                safeAreaTop = self.topLayoutGuide.length
            }
            let header = UILabel.init(frame: CGRect.init(x: 0, y: safeAreaTop, width: self.messagesCollectionView.frame.size.width, height: 50))
            header.backgroundColor = .black
            header.textColor = .white
            header.font = .systemFont(ofSize: 15)
            if messageObject.count == 1 {
                header.text = " Found \(messageObject.count ) Chat"
            }else if messageObject.count > 0 {
                header.text = " Found \(messageObject.count ) Chats"
            }else {
                header.text = " No Chats Found!"
            }
            
            view.addSubview(header)
            
        }
        
        self.hideLoading()
        messagesCollectionView.reloadData()
        DispatchQueue.main.async {
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
//        if messages?.count == 0{
//            self.alert("No Messages found")
//        }
    }
    
    func noChatsFound() {
        let safeAreaTop: CGFloat

        if #available(iOS 11.0, *) {
            safeAreaTop = self.view.safeAreaInsets.top
        } else {
            safeAreaTop = self.topLayoutGuide.length
        }
        let header = UILabel.init(frame: CGRect.init(x: 0, y: safeAreaTop , width: self.messagesCollectionView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        header.font = .systemFont(ofSize: 15)
        header.text = " No Chats Found!"
        self.view.addSubview(header)
        self.hideLoading()
        messagesCollectionView.reloadData()
    }
    
    func showMessage(obj: Conversation, user: SenderType){
        if obj.mediaType != 1 {
            
            let fullString = NSMutableAttributedString(string: "")
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = showMediaIcon(mediaType: obj.mediaType)
            let image1String = NSAttributedString(attachment: image1Attachment)
            fullString.append(image1String)
            fullString.append(NSAttributedString(string: "  " ))
            fullString.append(NSAttributedString(string:  obj.mediaName ?? "", attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor(white: 0.3, alpha: 0.7)
            ]))
            fullString.append(NSAttributedString(string:  "\n\n View attachment" , attributes: [
                .font: UIFont.systemFont(ofSize: 15, weight: .regular),
                .foregroundColor: UIColor.blue
            ]))
            
            messageObject.append(Message(sender: user,
                                         messageId: obj.id!,
                                         sentDate: Date().ttceISODate(isoDate: obj.createdOn!),
                                         kind: .attributedText(fullString), id: obj.mediaType, mediaName: obj.mediaName!, pathName: obj.path!, resolved: 0))
        }
        else{
            messageObject.append(Message(sender: user,
                                         messageId: obj.id!,
                                         sentDate: Date().ttceISODate(isoDate: obj.createdOn!),
                                         kind: .text(obj.messageString ?? ""), id: obj.mediaType, mediaName: obj.mediaName!, pathName: obj.path!, resolved: 0))
        }
    }
    
    func showMediaIcon(mediaType: Int) -> UIImage {
        var image: UIImage?
        switch(mediaType){
        case 2:
            image = UIImage(systemName: "doc.fill")?.withTintColor(#colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
        case 3:
            image = UIImage(systemName: "photo.fill")?.withTintColor(#colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1))
        case 4:
            image = UIImage(systemName: "mic.fill")?.withTintColor(#colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1))
        case 5:
            image = UIImage(systemName: "video.fill")?.withTintColor(#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1))
        default:
            image = UIImage(systemName: "paperclip")
        }
        return image!
    }
    
    func currentSender() -> SenderType {
        return currentUser
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//           return 50
//    }
    
    //func height
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: messagesCollectionView.frame.size.width, height: 50))
        header.backgroundColor = .black
        header.textColor = .white
        if messageObject.count == 1 {
            header.text = " Found \(messageObject.count ) message"
        }else if messageObject.count > 0 {
            header.text = " Found \(messageObject.count ) messages"
        }else {
            header.text = " No messages found!"
        }
        header.font = .systemFont(ofSize: 15)
        return (header as? MessageReusableView)!
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1): #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageObject[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        messageObject.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if messageObject[indexPath.section].sender.senderId == "1"{
            avatarView.initials = "B"
        }
        else{
            avatarView.initials = "A"
        }
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
}

extension ChatDetailsController: MessageCellDelegate, OpenAttachmentViewProtocol {
    
    func cancelButtonSelected() {
        self.view.hideOpenAttachmentView()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if message.id != 1 {
            let enquiryId = self.enquiryId
            let mediaName = message.mediaName
            let url = KeychainManager.standard.imageBaseURL + "/ChatBoxMedia/\(enquiryId ?? 0)/" + mediaName
            self.view.showOpenAttachmentView(controller: self, data: url)
        }
        else{
            print("Message tapped")
        }
        
    }
}

