//
//  PaymentUploadController:.swift
//  CraftExchange
//
//  Created by Kiran Songire on 28/09/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Foundation
import UIKit
import Bond
import Contacts
import ContactsUI
import Eureka
import ReactiveKit
import UIKit
import Reachability
import JGProgressHUD
import RealmSwift
import Realm
import ImageRow
import ViewRow
import WebKit

class UploadPaymentViewModel {
    var imageData = Observable<Data?>(nil)
    var fileName = Observable<String?>(nil)
    var paidAmount =  Observable<String?>(nil)
    var percentage = Observable<String?>(nil)
    var totalAmount = Observable<String?>(nil)
    var pid = Observable<String?>(nil)
}

class PaymentUploadController: FormViewController{
    
    var enquiryObject: Enquiry?
    var viewWillAppear: (() -> ())?
    let realm = try? Realm()
    var isClosed = false
    var editEnabled = true
    var data : Data?
    lazy var viewModel = UploadPaymentViewModel()
    var uploadReciept: (() -> ())?
    var imageReciept: (() -> ())?
    var receipt: PaymentArtist?
    //    let parentVC = self.parent as? PaymentUploadController
    override func viewDidLoad() {
        super.viewDidLoad()
        imageReciept?()
        self.view.backgroundColor = .white
        self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
        let accountDetails = realm?.objects(PaymentAccDetails.self).filter("%K == %@","userId",enquiryObject?.userId ?? 0)
        
        form
            +++ Section()
            <<< EnquiryDetailsRow(){
                $0.tag = "EnquiryDetailsRow"
                $0.cell.height = { 220.0 }
                $0.cell.statusLbl.text = "10 days remaining to upload receipt"
                $0.cell.statusLbl.textColor = UIColor.black
                $0.cell.statusDotView.isHidden = true
                $0.cell.prodDetailLbl.text = "\(ProductCategory.getProductCat(catId: enquiryObject?.productCategoryId ?? 0)?.prodCatDescription ?? "") / \(Yarn.getYarn(searchId: enquiryObject?.warpYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.weftYarnId ?? 0)?.yarnDesc ?? "-") x \(Yarn.getYarn(searchId: enquiryObject?.extraWeftYarnId ?? 0)?.yarnDesc ?? "-")"
                if enquiryObject?.productType == "Custom Product" {
                    $0.cell.designByLbl.text = "Requested Custom Design"
                }else {
                    $0.cell.designByLbl.text = enquiryObject?.brandName
                }
                $0.cell.amountLbl.text = enquiryObject?.totalAmount != 0 ? "\(enquiryObject?.totalAmount ?? 0)" : "NA"
                if let date = enquiryObject?.lastUpdated {
                    $0.cell.dateLbl.text = "Last updated: \(Date().ttceFormatter(isoDate: date))"
                }
                if let tag = enquiryObject?.productImages?.components(separatedBy: ",").first, let prodId = enquiryObject?.productId {
                    if let downloadedImage = try? Disk.retrieve("\(prodId)/\(tag)", from: .caches, as: UIImage.self) {
                        $0.cell.productImage.image = downloadedImage
                    }else {
                        do {
                            let client = try SafeClient(wrapping: CraftExchangeImageClient())
                            let service = ProductImageService.init(client: client)
                            service.fetch(withId: prodId, withName: tag).observeNext { (attachment) in
                                DispatchQueue.main.async {
                                    _ = try? Disk.saveAndURL(attachment, to: .caches, as: "\(prodId)/\(tag)")
                                    let row = self.form.rowBy(tag: "EnquiryDetailsRow") as! EnquiryDetailsRow
                                    row.cell.productImage.image = UIImage.init(data: attachment)
                                    row.reload()
                                }
                            }.dispose(in: bag)
                        }catch {
                            print(error.localizedDescription)
                        }
                        
                    }
                }
            }
            <<< LabelRow(){
                $0.title = "Upload the Payment Receipt to Confirm"
                if enquiryObject!.isBlue {
                    $0.hidden = true
                }
            }
            <<< BuyerEnquirySectionViewRow() {
                $0.cell.height = { 44.0 }
                if User.loggedIn()?.refRoleId == "2" {
                    $0.cell.titleLbl.text = "Brand: \(enquiryObject?.brandName ?? "NA")"
                }else {
                    $0.cell.titleLbl.text = ""
                }
                if enquiryObject!.isBlue {
                    $0.hidden = true
                }
                
                $0.cell.valueLbl.text = "Check Artisn's Payment details"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                $0.cell.titleLbl.textColor = UIColor().EQBlueText()
                $0.cell.valueLbl.textColor = UIColor().EQBlueText()
            }.onCellSelection({ (cell, row) in
                let row1 = self.form.rowBy(tag: "AccountDetails")
                let row2 = self.form.rowBy(tag: "Gpay")
                let row3 = self.form.rowBy(tag: "Paytm")
                let row4 = self.form.rowBy(tag: "PhonePay")
                
                if row1?.isHidden == true {
                    row1?.hidden = false
                    row2?.hidden = false
                    row3?.hidden = false
                    row4?.hidden = false
                }else {
                    row1?.hidden = true
                    row2?.hidden = true
                    row3?.hidden = true
                    row4?.hidden = true
                }
                row1?.evaluateHidden()
                row2?.evaluateHidden()
                row3?.evaluateHidden()
                row4?.evaluateHidden()
                self.form.allSections.first?.reload(with: .none)
            })
            <<< TextRow() {
                $0.tag = "AccountDetails"
                $0.cell.height = { 40.0 }
                var nameString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 1 {
                        nameString = account.name ?? ""
                    }
                })
                $0.title = "Account Details: \(nameString)"
                
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                
                $0.hidden = true
            }.cellUpdate({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.isUserInteractionEnabled = false
                cell.textField.layer.borderColor = UIColor.white.cgColor
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 2 {
                        valueString = "\(account.bankName ?? ""), \(account.branchName ?? ""), Account No:  \(account.AccNoUpiMobile ?? ""), IFSC Code: \(account.ifsc ?? "")"
                    }
                    cell.textLabel?.textColor = .black
                    cell.textLabel?.font = .systemFont(ofSize: 14, weight: .regular)
                })
                cell.textField.text = valueString
            })
            <<< PaymentModeRow() {
                $0.cell.height = { 50.0 }
                $0.tag = "Gpay"
                $0.cell.paymentIcon.image = UIImage.init(named: "gPayIcon")
                $0.cell.PaymentModeLbl.text = "Google Pay UPI Id"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 2 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.PaymentValueLbl.text = valueString
                $0.hidden = true
            }
            
            <<< PaymentModeRow() {
                $0.cell.height = { 50.0 }
                $0.tag = "Paytm"
                $0.cell.paymentIcon.image = UIImage.init(named: "paytmIcon")
                $0.cell.PaymentModeLbl.text = "Paytm Registered Mobile Number"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 4 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.PaymentValueLbl.text = valueString
                $0.hidden = true
            }
            
            <<< PaymentModeRow() {
                $0.cell.height = { 50.0 }
                $0.tag = "PhonePay"
                $0.cell.paymentIcon.image = UIImage.init(named: "phone-pe")
                $0.cell.PaymentModeLbl.text = "Resgistered Number for PhonePay"
                $0.cell.contentView.backgroundColor = UIColor().EQBlueBg()
                var valueString = ""
                accountDetails?.compactMap({$0}) .forEach({ (account) in
                    if account.accType == 3 {
                        valueString = account.AccNoUpiMobile ?? ""
                    }
                })
                $0.cell.PaymentValueLbl.text = valueString
                $0.hidden = true
            }
            
            <<< uploadRecieptRow("uploadReceipt") {
                $0.cell.height = { 375.0 }
                $0.tag = "uploadReceipt"
                $0.cell.delegate = self
                if enquiryObject!.isBlue || enquiryObject!.enquiryStageId >= 4{
                    $0.hidden = true
                }
            }
            
            <<< UploadSuccessfulRow("uploadsuccess") {
                $0.cell.height = { 375 }
                $0.tag = "uploadsuccess"
                $0.cell.delegate = self
                $0.cell.Tick.layer.cornerRadius = 30
                $0.cell.Tick.layer.borderColor = #colorLiteral(red: 0.2589518452, green: 0.5749325825, blue: 0.166714282, alpha: 1)
                $0.cell.Tick.layer.borderWidth = 2
                $0.hidden = true
                if enquiryObject!.isBlue || enquiryObject!.enquiryStageId >= 4{
                    $0.hidden = false
                }
        }
    }
    
    func reloadAddPhotoRow() {
        let row = self.form.rowBy(tag: "uploadReceipt")
        row?.reload()
        
    }
}

extension PaymentUploadController: uploadtransactionProtocol, uploadSuccessProtocol, TransactionReceiptViewProtocol {
    
    func cancelBtnSelected() {
        self.view.hideTransactionReceiptView()
    }
    
    func ViewTransactionBtnSelected(tag: Int) {
        showLoading()
        imageReciept?()
        if self.data != nil{
             self.view.showTransactionReceiptView(controller: self, data: self.data!)
        }
       
       self.hideLoading()
    }
    
    func UploadBtnSelected(tag: Int) {
        self.showLoading()
        self.uploadReciept?()
    }
    
    func UploadImageBtnSelected(tag: Int) {
        self.showImagePickerAlert()
    }
    
}

extension PaymentUploadController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            print("Image not found!")
            return
        }
        let row = self.form.rowBy(tag: "uploadReceipt") as? uploadRecieptRow
        row?.cell.uploadImgBtn.setImage(selectedImage, for: .normal)
        row?.cell.uploadImgBtn.imageView?.layer.cornerRadius = 60
        
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
        self.viewModel.imageData.value = imgdata
        self.viewModel.fileName.value = "\(self.enquiryObject!.enquiryId).\(Int(viewModel.pid.value!)!).jpg"
        picker.dismiss(animated: true) {
            self.reloadAddPhotoRow()
        }
    }
}
