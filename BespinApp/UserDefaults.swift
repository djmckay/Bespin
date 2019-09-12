//
//  UserDefaults.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

class UserDefaultsManager {
    
    
    //static let defaults: NSUbiquitousKeyValueStore? = NSUbiquitousKeyValueStore.default
    static let defaults: UserDefaults? = UserDefaults.standard
    
    
    static var standard: [String : Any?] {
        get {
            if defaults?.dictionary(forKey: "standard") == nil {
                defaults?.set([String : Any](), forKey: "standard")
            }
            return (defaults?.dictionary(forKey: "standard"))!
        }
        set {
            defaults?.set(newValue, forKey: "standard")
        }
    }
    
    static var notifications: [String : Any?] {
        get {
            if defaults?.dictionary(forKey: "notifications") == nil {
                defaults?.set([String : Any](), forKey: "notifications")
            }
            return (defaults?.dictionary(forKey: "notifications"))!
        }
        set {
            defaults?.set(newValue, forKey: "notifications")
        }
    }
    
    static var deviceToken: String? {
        get {
            return defaults?.string(forKey: "deviceToken")
        }
        set {
            defaults?.set(newValue, forKey: "deviceToken")
        }
    }
    
    static var isLoggedIn: Bool {
        get {
            if defaults?.bool(forKey: "isLoggedIn") == nil {
                defaults?.set(false, forKey: "isLoggedIn")
            }
            return defaults!.bool(forKey: "isLoggedIn")
        }
        set {
            defaults?.set(newValue, forKey: "isLoggedIn")
        }
    }
    
    static var loggedInUser: User? {
        get {
            guard let data = defaults?.value(forKey: "loggedInUser") as? Data else { return nil }
            let user = try? PropertyListDecoder().decode(User.self, from: data)
            return user
        }
        set {
            guard newValue != nil else {defaults?.setValue(nil, forKey: "loggedInUser"); return }
            do {
            let list = try PropertyListEncoder().encode(newValue)
            defaults?.setValue(list, forKey: "loggedInUser")
            } catch {
                print(error.localizedDescription)
            }
            
            
        }
    }
    
//    static var hasRegisteredUser: Bool {
//        get {
//            if defaults?.bool(forKey: "hasRegisteredUser") == nil {
//                defaults?.set(false, forKey: "hasRegisteredUser")
//            }
//            return defaults!.bool(forKey: "hasRegisteredUser")
//        }
//        set {
//            defaults?.set(newValue, forKey: "hasRegisteredUser")
//        }
//    }
    
    static var hasRegisteredRemote: Bool {
        get {
            if defaults?.bool(forKey: "hasRegisteredRemote") == nil {
                defaults?.set(false, forKey: "hasRegisteredRemote")
            }
            return defaults!.bool(forKey: "hasRegisteredRemote")
        }
        set {
            defaults?.set(newValue, forKey: "hasRegisteredRemote")
        }
    }
    
    static var hasCreatedAuthUser: Bool {
        get {
            if defaults?.bool(forKey: "hasCreatedAuthUser") == nil {
                defaults?.set(false, forKey: "hasCreatedAuthUser")
            }
            return defaults!.bool(forKey: "hasCreatedAuthUser")
        }
        set {
            defaults?.set(newValue, forKey: "hasCreatedAuthUser")
        }
    }
    
    static var session: String? {
        get {
            return defaults?.string(forKey: "session")
        }
        set {
            defaults?.set(newValue, forKey: "session")
        }
    }
    
    static var basicAuthorization: String? {
        get {
            return defaults?.string(forKey: "basicAuthorization")
        }
        set {
            defaults?.set(newValue, forKey: "basicAuthorization")
        }
    }
    
    static func resetNotifications() {
        notifications.removeAll()
    }
    
}
