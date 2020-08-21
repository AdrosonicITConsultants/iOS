//
//  KeychainManager.swift
//  Knowledgemill
//
//  Created by Monty Dudani on 19/10/19.
//  Copyright © 2019 ADROSONIC. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class KeychainManager {

    static let standard = KeychainManager()

    let keychain: KeychainWrapper
    let defaults: UserDefaults

    private init() {
        keychain = KeychainWrapper.standard
        defaults = UserDefaults.standard
    }

    func deleteAll() {
        keychain.removeAllKeys()
        let keys = defaults.dictionaryRepresentation().keys
        print("all keys \(keys)")
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        for key in Array(keys) { defaults.removeObject(forKey: key) }
        defaults.synchronize()
    }

    var userID: Int? {
        get {
            defaults.integer(forKey: "cx_user_id")
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "cx_user_id")
            } else {
                defaults.removeObject(forKey: "cx_user_id")
            }
        }
    }

    var username: String? {
        get {
            keychain.string(forKey: "cx_username")
        }
        set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: "cx_username")
            } else {
                keychain.removeObject(forKey: "cx_username")
            }
        }
    }

    var password: String? {
        get {
            keychain.string(forKey: "cx_password")
        }
        set {
            if let newValue = newValue {
                keychain.set(newValue, forKey: "cx_password")
            }
            else {
                keychain.removeObject(forKey: "cx_password")
            }
        }
    }

    var baseURL: String {
        return "http://101.53.153.96:8090"
    }
    
    var imageBaseURL: String {
        return "https://f3adac-craft-exchange-resource.objectstore.e2enetworks.net"
    }
  
    var userRole: String? {
        get {
            defaults.string(forKey: "cx_user_role")
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "cx_user_role")
            } else {
                defaults.removeObject(forKey: "cx_user_role")
            }
        }
    }
  
    var userRoleId: Int? {
        get {
            defaults.integer(forKey: "cx_user_roleId")
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "cx_user_roleId")
            } else {
                defaults.removeObject(forKey: "cx_user_roleId")
            }
        }
  }
  
  var userAccessToken: String? {
        get {
            defaults.string(forKey: "AccessToken")
        }
        set {
            if let newValue = newValue {
                defaults.set(newValue, forKey: "AccessToken")
            } else {
                defaults.removeObject(forKey: "AccessToken")
            }
        }
  }
}
