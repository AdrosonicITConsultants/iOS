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
import InputBarAccessoryView
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
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Audio: AudioItem {
    var url: URL
    var duration: Float
    var size: CGSize
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


class ChatDetailsController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    
    var chatObj: Chat!
    var messages: [Conversation]?
    var reachabilityManager = try? Reachability()
    var applicationEnteredForeground: (() -> ())?
    let realm = try? Realm()
    var id: [Int] = []
    var viewWillAppear: (() -> ())?
    var sendMessage: (() -> ())?
    var downloadEnquiry: ((_ enquiryId: Int) -> ())?
    var goToEnquiry: ((_ enquiryId: Int) -> ())?
    var sendMedia: (() -> ())?
    lazy var viewModel = SendMessageViewModel()
    let currentUser = Sender(senderId: "\(KeychainManager.standard.userID!)", displayName: KeychainManager.standard.username!)
    var otherUser:Sender?
    var messageObject = [MessageType]()
    var Bubble: TypingBubble?
    var user: User?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.contentInset.top = 150
        
       // messagesCollectionView.topAnchor = NSLayoutConstraint()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        showMessageTimestampOnSwipeLeft = true
        
        let image2View = UIImageView(frame: CGRect(x: 0, y: UIScreen.main.bounds.midY-167, width: 415, height: 254))
        image2View.image = #imageLiteral(resourceName: "ChatCx.pdf")
        messagesCollectionView.backgroundView =  UIImageView(image:#imageLiteral(resourceName: "ChatBg.pdf") )
        messagesCollectionView.backgroundView?.addSubview(image2View)
        additionalBottomInset = 50
        
        messageInputBar.inputTextView.tintColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        messageInputBar.inputTextView.placeholder = "Type your message here"
        messageInputBar.sendButton.setTitleColor(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), for: .normal)
        messageInputBar.delegate = self
        setupInputButton()
        messages = []
        
        
        definesPresentationContext = false
        self.setupSideMenu(true)
        let center = NotificationCenter.default
        center.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: OperationQueue.main) { (notification) in
            self.applicationEnteredForeground?()
        }
        
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 45, height: 45), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside{ [weak self] _ in
            self?.presentInputActionsheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 45, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputActionsheet(){
        let alert = UIAlertController.init(title: "", message: "Choose".localized, preferredStyle: .actionSheet)
        
        let docs = UIAlertAction.init(title: "Docs".localized, style: .default) { (action) in
            // self.goToChat()
            self.DocPickerAlert()
            
        }
        alert.addAction(docs)
        
        let image = UIAlertAction.init(title: "Image", style: .default) { (action) in
            self.ImagePickerAlert()
        }
        alert.addAction(image)
        
        let audio = UIAlertAction.init(title: "Audio", style: .default) { (action) in
            self.AudioPickerAlert()
        }
        alert.addAction(audio)
        
        let video = UIAlertAction.init(title: "Video", style: .default) { (action) in
            self.videoPickerAlert()
        }
        alert.addAction(video)
        
        let cancel = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func sendInputActionsheet(mediaName: String?){
        let alert = UIAlertController.init(title: "Are you sure", message: "you want to send " + mediaName! + "?", preferredStyle: .actionSheet)
        
        let save = UIAlertAction.init(title: "Send", style: .default) { (action) in
            self.sendMedia?()
        }
        alert.addAction(save)
        let cancel = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func DocPickerAlert()  {
       
        let DocPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypePDF), String(kUTTypeText), String(kUTTypeSpreadsheet), "com.microsoft.word.doc" as String, "org.openxmlformats.wordprocessingml.document" as String, "org.openxmlformats.presentationml.presentation" as String, "com.microsoft.powerpoint.​ppt" as String], in: .open)
        
        DocPicker.delegate = self as UIDocumentPickerDelegate
        DocPicker.allowsMultipleSelection = false
        self.present(DocPicker, animated: true, completion: nil)
        
    }
    
    func ImagePickerAlert(){
        let alert = UIAlertController.init(title: "Please Select:".localized, message: "Options:".localized, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "Camera".localized, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker =  UIImagePickerController()
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alert.addAction(action1)
        let action2 = UIAlertAction.init(title: "Gallery".localized, style: .default) { (action) in
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        alert.addAction(action2)
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func AudioPickerAlert()  {
       
        let AudioPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMP3 as String, kUTTypeAudio as String], in: .open)
        
        AudioPicker.delegate = self as UIDocumentPickerDelegate
        AudioPicker.allowsMultipleSelection = false
        self.present(AudioPicker, animated: true, completion: nil)
        
    }
    
    func videoPickerAlert(){
        let alert = UIAlertController.init(title: "Please Select:".localized, message: "Options:".localized, preferredStyle: .actionSheet)
        let action1 = UIAlertAction.init(title: "Camera".localized, style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker =  UIImagePickerController()
                imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
                imagePicker.sourceType = .camera
                imagePicker.allowsEditing = true
                imagePicker.mediaTypes = ["public.movie"]
                imagePicker.videoQuality = .typeMedium
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        alert.addAction(action1)
        let action2 = UIAlertAction.init(title: "Gallery".localized, style: .default) { (action) in
            let imagePicker =  UIImagePickerController()
            imagePicker.delegate = self as UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = ["public.movie"]
            imagePicker.videoQuality = .typeMedium
            self.present(imagePicker, animated: true, completion: nil)
        }
        alert.addAction(action2)
        let action = UIAlertAction.init(title: "Cancel", style: .cancel) { (action) in
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWillAppear?()
        //self.view.showChatHeaderView(controller: self, chat: chatObj)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.view.showChatHeaderView(controller: self, chat: chatObj)
    }
    
    func endRefresh() {
        

        messages = realm?.objects(Conversation.self).filter("%K IN %@","entityID", id ).sorted(byKeyPath: "entityID", ascending: true).compactMap({$0})
        otherUser = Sender(senderId: "\(chatObj.buyerId)", displayName: chatObj.buyerCompanyName!)

        
        if messages != []{
            for obj in messages! {
                if self.chatObj?.buyerId != obj.messageFrom {
                    showMessage(obj: obj, user: currentUser)
                }else{
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
    
    func showMessage(obj: Conversation, user: SenderType){
        if obj.mediaType != 1 {
            
            let fullString = NSMutableAttributedString(string: "")
            
            let image1Attachment = NSTextAttachment()
            image1Attachment.image = showMediaIcon(mediaType: obj.mediaType)
//            image1Attachment.bounds = CGRect(x: 2, y: 2, width: 20, height: 30)
            // wrap the attachment in its own attributed string so we can append it
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
                                         kind: .attributedText(fullString), id: obj.mediaType, mediaName: obj.mediaName!, pathName: obj.path!))
        }
        else{
            messageObject.append(Message(sender: user,
                                         messageId: obj.id!,
                                         sentDate: Date().ttceISODate(isoDate: obj.createdOn!),
                                         kind: .text(obj.messageString ?? ""), id: obj.mediaType, mediaName: obj.mediaName!, pathName: obj.path!))
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
        if messageObject[indexPath.section].sender.senderId == "\(KeychainManager.standard.userID!)"{
            avatarView.initials = "Me"
            // avatarView.image = #imageLiteral(resourceName: "Fabric.jpg")
            user = User.getUser(userId: KeychainManager.standard.userID!)
            
            if let tag = user?.buyerCompanyDetails.first?.logo, user?.buyerCompanyDetails.first?.logo != "" {
                let prodId = user!.entityID
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    avatarView.image = downloadedImage
                }else {
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
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        else{
            avatarView.initials = "They"
            // avatarView.image = #imageLiteral(resourceName: "Home accessories.jpg")
            
            if let tag = chatObj.buyerLogo, chatObj.buyerLogo != "" {
                let prodId = chatObj.buyerId
                if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                    avatarView.image = downloadedImage
                }else {
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
                    }catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        //When use press send button this method is called.
        viewModel.enquiryId.value = self.chatObj.enquiryId
        viewModel.messageTo.value = self.chatObj.buyerId
        viewModel.messageFrom.value = KeychainManager.standard.userID!
        viewModel.messageString.value = text
        viewModel.mediaType.value = 1
        sendMessage?()
        //clearing input field
        inputBar.inputTextView.text = ""
        
    }
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    
    
}

extension ChatDetailsController: MessageCellDelegate, ChatHeaderDetailsViewProtocol, ChatHeaderViewProtocol  {
    func escalationButtonSelected() {
       print("Escaltion button selected")
    }
    
    func viewDetailsButtonSelected() {
        self.view.showChatHeaderDetailsView(controller: self, chat: chatObj)
    }
    
    func goToEnquiryButtonSelected() {
        self.downloadEnquiry?(chatObj.enquiryId)
    }
    
    func closeDetailsButtonSelected() {
        self.view.hideChatHeaderDetailsView()
    }
    
    func cancelButtonSelected() {
        self.view.hideOpenAttachmentView()
        self.inputAccessoryView?.isHidden = false
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        guard let messagesDataSource = messagesCollectionView.messagesDataSource else { return }
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if message.id != 1 {
            let enquiryId = chatObj.enquiryId
            let mediaName = message.mediaName
            // /ChatBoxMedia/1892/VDO_45004.mp4
            let url = KeychainManager.standard.imageBaseURL + "/ChatBoxMedia/\(enquiryId)/" + mediaName
            self.view.showOpenAttachmentView(controller: self, data: url)
            if message.id == 4{
                self.inputAccessoryView?.isHidden = false
            }else{
                self.inputAccessoryView?.isHidden = true
            }
        }
        else{
            print("Message tapped")
        }
        
    }
}

extension ChatDetailsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]){
        let docData =  try! NSData(contentsOf: urls.first!, options: .mappedIfSafe)
        self.viewModel.enquiryId.value = self.chatObj.enquiryId
        self.viewModel.messageTo.value = self.chatObj.buyerId
        self.viewModel.messageFrom.value = KeychainManager.standard.userID!
        self.viewModel.mediaType.value = 2
         self.viewModel.mediaData.value = Data(referencing: docData)
        self.viewModel.fileName.value = urls.first?.lastPathComponent
        if  urls.first!.pathExtension == "mp3" || urls.first!.pathExtension == "audio" {
            self.viewModel.mediaType.value = 4
        }
        
        self.sendInputActionsheet(mediaName: urls.first?.lastPathComponent)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let selectedImage = info[.editedImage] as? UIImage {
            var imgdata: Data?
            if let compressedImg = selectedImage.resizedTo1MB() {
                if let data = compressedImg.pngData() {
                    imgdata = data
                } else if let data = compressedImg.jpegData(compressionQuality: 1) {
                    imgdata = data
                }
            }else {
                if let data = selectedImage.pngData() {
                    imgdata = data
                } else if let data = selectedImage.jpegData(compressionQuality: 0.5) {
                    imgdata = data
                }
            }
            
            if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                self.viewModel.enquiryId.value = self.chatObj.enquiryId
                self.viewModel.messageTo.value = self.chatObj.buyerId
                self.viewModel.messageFrom.value = KeychainManager.standard.userID!
                self.viewModel.mediaType.value = 3
                self.viewModel.mediaData.value = imgdata
                self.viewModel.fileName.value = url.lastPathComponent
                self.sendInputActionsheet(mediaName: url.lastPathComponent)
            }
        }
        else if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let videoData = try! NSData(contentsOf: url, options: .mappedIfSafe)
            self.viewModel.enquiryId.value = self.chatObj.enquiryId
            self.viewModel.messageTo.value = self.chatObj.buyerId
            self.viewModel.messageFrom.value = KeychainManager.standard.userID!
            self.viewModel.mediaType.value = 5
             self.viewModel.mediaData.value = Data(referencing: videoData)
            self.viewModel.fileName.value = url.lastPathComponent
            self.sendInputActionsheet(mediaName: url.lastPathComponent)
        } else {
            print("Image not found!")
            return
        }
        
        
        
        picker.dismiss(animated: true)
    }
}

