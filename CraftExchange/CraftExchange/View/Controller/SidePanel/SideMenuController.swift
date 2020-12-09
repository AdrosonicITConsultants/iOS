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
                    hiLbl.text = "Hi,".localized + "\n\(KeychainManager.standard.username ?? "")"
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
                $0.title = "My Profile".localized
                $0.cellStyle = .default
                $0.cell.imageView?.image = UIImage(named: "my-profile-icon")
                $0.cell.height = { 56.0 }
            }.onCellSelection { (cell, row) in
                self.dismiss(animated: true, completion: {
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
                row.title = "My Transactions".localized
                row.cell.imageView?.image = UIImage(named: "ios_transactions")
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.height = { 56.0 }
            }.onCellSelection { (cell, row) in
                self.dismiss(animated: true, completion: {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeClient())
                        let vc = TransactionService(client: client).createScene()
                        let nav = self.getNavBar()
                        nav?.pushViewController(vc, animated: true)
                    } catch let error {
                        print("Unable to load view:\n\(error.localizedDescription)")
                    }
                })
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
            <<< LabelRow() { row in
                row.title = "My Orders".localized
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.imageView?.image = UIImage(named: "tab-enquiries")
                row.cell.height = { 56.0 }
            }.onCellSelection { (cell, row) in
                self.dismiss(animated: true, completion: {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeClient())
                        let vc = OrderListService(client: client).createScene()
                        let nav = self.getNavBar()
                        nav?.pushViewController(vc, animated: true)
                    } catch let error {
                        print("Unable to load view:\n\(error.localizedDescription)")
                    }
                })
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
            <<< LabelRow() { row in
                row.title = "Custom Design".localized
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.imageView?.image = UIImage(named: "custom-design-icon")
                row.cell.height = { 56.0 }
                row.hidden = KeychainManager.standard.userRoleId == 1 ? true : false
            }.onCellSelection { (cell, row) in
                self.dismiss(animated: true, completion: {
                    do {
                        let client = try SafeClient(wrapping: CraftExchangeClient())
                        let vc = CustomProductService(client: client).createScene()
                        let nav = self.getNavBar()
                        nav?.pushViewController(vc, animated: true)
                    } catch let error {
                        print("Unable to load view:\n\(error.localizedDescription)")
                    }
                })
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
            <<< LabelRow() { row in
                row.title = "My Dashboard".localized
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.imageView?.image = UIImage(named: "ios_mydash")
                row.cell.height = { 56.0 }
            }.onCellSelection { (cell, row) in
                self.dismiss(animated: true, completion:
                    {
                        do {
                            
                            let dashboardStoryboard = UIStoryboard.init(name: "MyDashboard", bundle: Bundle.main)
                            let vc = dashboardStoryboard.instantiateViewController(withIdentifier: "DashboardController") as! DashboardController
                            
                            let appDelegate = UIApplication.shared.delegate as? AppDelegate
                            var nav: UINavigationController?
                            if let tab = appDelegate?.tabbar?.selectedViewController as? UINavigationController {
                                nav = tab
                            }else if let tab = appDelegate?.tabbar?.selectedViewController?.navigationController {
                                nav = tab
                            }
                            else if let tab = appDelegate?.artisanTabbar?.selectedViewController as? UINavigationController {
                                nav = tab
                            }else if let tab = appDelegate?.artisanTabbar?.selectedViewController?.navigationController {
                                nav = tab
                            }
                            nav?.pushViewController(vc, animated: true)
                            
                        }
                        catch let error {
                            print("Unable to load view:\n\(error.localizedDescription)")
                        }
                })
                
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
            <<< LabelRow() { row in
                row.title = "Support".localized
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.imageView?.image = UIImage(named: "ios_help")
                row.cell.height = { 56.0 }
            }.onCellSelection { (cell, row) in
//                self.alert("For any support","please write to us at craftxchange.tatatrusts@gmail.com" )
                self.dismiss(animated: true, completion: {
                    
                    do {
                        self.getNavBar()?.topViewController?.didTapFAQButton(tag: 5)
                        
                    } catch let error {
                        print("Unable to load view:\n\(error.localizedDescription)")
                    }
                })
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
            <<< LabelRow() { row in
                row.title = "Change Language".localized
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.imageView?.image = UIImage(named: "change language")
                row.cell.height = { 56.0 }
                row.hidden = KeychainManager.standard.userRoleId == 2 ? true : false
            }.onCellSelection { (cell, row) in
                self.showLanguagePickerAlert()
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
            <<< LabelRow() { row in
                row.title = "Logout".localized
                row.cell.textLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
                row.cell.imageView?.image = UIImage(named: "ios_logout")
                row.cell.height = { 56.0 }
            }.onCellSelection { (cell, row) in
                self.sendInputActionsheet()
            }.cellUpdate({ (str, row) in
                row.cell.textLabel?.textColor = UIColor().menuTitleBlue()
            })
        
        
        let view = UIImageView.init(image: UIImage(named: "ios_logo_ham menu"))
        let ht: CGFloat = 140.0
        view.frame = CGRect(x: 0, y: self.view.frame.height-ht, width: min(self.view.frame.width, self.view.frame.height) * CGFloat(0.80), height: ht)
        view.contentMode = .center
        
        let lbl = UILabel.init(frame: CGRect(x: 0, y: self.view.frame.size.height-30, width: view.frame.size.width, height: 20))
        lbl.font = .systemFont(ofSize: 10)
        lbl.textColor = .lightGray
        lbl.textAlignment = .center
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        lbl.text = "10-12-2020 V\(appVersion ?? "1.2")"
        self.view.addSubview(lbl)
        self.view.addSubview(view)
    }
    
    func sendInputActionsheet(){
        let alert = UIAlertController.init(title: "Are you sure".localized, message: "you want to logout?", preferredStyle: .actionSheet)
        
        let save = UIAlertAction.init(title: "Logout".localized, style: .default) { (action) in
            
            guard let client = try? SafeClient(wrapping: CraftExchangeClient()) else {
                _ = NSError(domain: "Network Client Error", code: 502, userInfo: nil)
                return
            }
            LoginUserService(client: client).logoutFunc(vc: self)
            
        }
        alert.addAction(save)
        let cancel = UIAlertAction.init(title: "Cancel".localized, style: .cancel) { (action) in
            
        }
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }

    func getNavBar() -> UINavigationController? {
        var nav: UINavigationController?
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        if let tab = appDelegate?.tabbar?.selectedViewController as? UINavigationController {
            nav = tab
        }else if let tab = appDelegate?.tabbar?.selectedViewController?.navigationController {
            nav = tab
        }else if let tab = appDelegate?.artisanTabbar?.selectedViewController as? UINavigationController {
            nav = tab
        }else if let tab = appDelegate?.artisanTabbar?.selectedViewController?.navigationController {
            nav = tab
        }
        return nav
    }
}
