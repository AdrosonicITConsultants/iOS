//
//  SideMenuController.swift
//  CraftExchange
//
//  Created by Preety Singh on 22/06/20.
//  Copyright © 2020 Adrosonic. All rights reserved.
//

import Eureka
import ReactiveKit
import Bond
import RealmSwift
import JGProgressHUD

class SideMenuController: FormViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView?.separatorStyle = UITableViewCell.SeparatorStyle.none
    self.navigationController?.setToolbarHidden(true, animated: true)
    
      form +++ Section(){ section in
          let ht: CGFloat = 120.0
        let width: CGFloat = min(self.view.frame.width, self.view.frame.height) * CGFloat(0.80)
          section.header = {
                var header = HeaderFooterView<UIView>(.callback({
                  let view = UIView(frame: CGRect(x: 0, y: self.view.frame.height-ht, width: width, height: ht))
                  
                  let hiLbl = UILabel.init(frame: CGRect(x: 20, y: 20, width: view.frame.width-120, height: ht-40))
                  hiLbl.font = .systemFont(ofSize: 24, weight: .semibold)
                  hiLbl.numberOfLines = 3
                  hiLbl.textColor = .black
                  hiLbl.text = "Hi,\n\(KeychainManager.standard.username ?? "")"
                  view.addSubview(hiLbl)
                  
                  let profileImg = UIImageView.init(image: UIImage(named: "person_icon"))
                  profileImg.frame = CGRect(x: hiLbl.frame.width + 20, y: 20, width: 80, height: 80)
                  profileImg.layer.cornerRadius = 50
                  view.addSubview(profileImg)
                  
                  let dottedLineView = UIView(frame: CGRect.init(x: 0, y: ht-2, width: width, height: 2))
                  dottedLineView.addDashedBorder()
                  view.addSubview(dottedLineView)
                  return view
                }))
                header.height = { ht }
                return header
              }()
        }
          <<< LabelRow() {
            $0.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            $0.title = "My Profile"
            $0.cellStyle = .default
            $0.cell.imageView?.image = UIImage(named: "my-profile-icon")
            $0.cell.height = { 56.0 }
          }.onCellSelection { (cell, row) in
              self.dismiss(animated: true, completion: {
//                  let profileStoryboard = UIStoryboard.init(name: "MyProfile", bundle: Bundle.main)
//                  let vc = profileStoryboard.instantiateViewController(identifier: "BuyerProfileController")
                do {
                  let client = try SafeClient(wrapping: CraftExchangeClient())
                  let vc = MyProfileService(client: client).createScene()
                      let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    var nav: UINavigationController?
                    if let tab = appDelegate?.tabbar?.selectedViewController as? UINavigationController {
                        nav = tab
                    }else if let tab = appDelegate?.tabbar?.selectedViewController?.navigationController {
                          nav = tab
                    }else if let tab = appDelegate?.artisanTabbar?.selectedViewController as? UINavigationController {
                        nav = tab
                    }else if let tab = appDelegate?.artisanTabbar?.selectedViewController?.navigationController {
                          nav = tab
                    }
                    nav?.pushViewController(vc, animated: true)
                } catch let error {
                  print("Unable to load view:\n\(error.localizedDescription)")
                }
              })
          }.cellUpdate({ (str, row) in
            row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
          })
          <<< LabelRow() { row in
            row.title = "My Transactions"
            row.cell.imageView?.image = UIImage(named: "ios_transactions")
            row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            row.cell.height = { 56.0 }
          }.onCellSelection { (cell, row) in
              self.dismiss(animated: true, completion: nil)
          }.cellUpdate({ (str, row) in
            row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
          })
          <<< LabelRow() { row in
            row.title = "My Orders"
            row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            row.cell.imageView?.image = UIImage(named: "tab-enquiries")
            row.cell.height = { 56.0 }
          }.onCellSelection { (cell, row) in
              self.dismiss(animated: true, completion: nil)
          }.cellUpdate({ (str, row) in
            row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
          })
          <<< LabelRow() { row in
            row.title = "My Dashboard"
            row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            row.cell.imageView?.image = UIImage(named: "ios_mydash")
            row.cell.height = { 56.0 }
          }.onCellSelection { (cell, row) in
              self.dismiss(animated: true, completion: nil)
          }.cellUpdate({ (str, row) in
            row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
          })
          <<< LabelRow() { row in
            row.title = "Support"
            row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            row.cell.imageView?.image = UIImage(named: "ios_help")
            row.cell.height = { 56.0 }
          }.onCellSelection { (cell, row) in
              self.dismiss(animated: true, completion: nil)
          }.cellUpdate({ (str, row) in
            row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
          })
          <<< LabelRow() { row in
            row.title = "Logout"
            row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            row.cell.imageView?.image = UIImage(named: "ios_logout")
            row.cell.height = { 56.0 }
          }.onCellSelection { (cell, row) in
            KeychainManager.standard.deleteAll()
            self.showLoading()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "RoleViewController") as! RoleViewController
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: {
              self.hideLoading()
            })
          }.cellUpdate({ (str, row) in
            row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
          })
    
    
    let view = UIImageView.init(image: UIImage(named: "ios_logo_ham menu"))
    let ht: CGFloat = 180.0
    view.frame = CGRect(x: 0, y: self.view.frame.height-ht, width: min(self.view.frame.width, self.view.frame.height) * CGFloat(0.80), height: ht)
    view.contentMode = .center
    self.view.addSubview(view)
  }
  
}
