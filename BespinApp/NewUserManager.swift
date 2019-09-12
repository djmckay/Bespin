//
//  NewUserManager.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

public class NewUserManager {
    
    static var sharedInstance = NewUserManager()
    fileprivate var inputTextTypes: [InputTextType]!
    
    func getInputs() {
        
    }
    func create(user: User, complete: @escaping ((_ status: Bool, _ error: Error?, _ auth: Bool) -> ())) {
        LoginManager.sharedInstance.createUser(username: user.username, password: user.password!) { (status, error) in
            if status {
                DataManager.sharedInstance.registerUser(user: user) { (result) in
                    switch result {
                    case .failure:
                        print("failed")
                        complete(false, error, false)
                    case .success(let user):
                        UserDefaultsManager.isLoggedIn = true
                        NotificationManager.notification().registerForPushNotifications()
                        complete(true, error, false)
                    }
                    
                    
                }
            } else {
                complete(status, error, true)
            }
        }
    }
    
    func update(user: User, isPasswordUpdate: Bool = false, complete: @escaping (User?) -> (), failure: @escaping () -> ()) {
        if isPasswordUpdate {
            self.changePassword(user: user, complete: complete, failure: failure)
        } else {
            DataManager.sharedInstance.updateUser(user: user) { result in
                
                switch result {
                    
                case .success(let userUpdate):
                    UserDefaultsManager.loggedInUser = userUpdate
                    complete(userUpdate)
                case .failure:
                    failure()
                }
                
            }
        }
        
    }
    
    func changePassword(user: User, complete: @escaping (User?) -> (), failure: @escaping () -> ()) {
        DataManager.sharedInstance.changePassword(user: user) { result in
            
            switch result {
                
            case .success(let userUpdate):
                if let password = user.password {
                    LoginManager.sharedInstance.newPassword(user: userUpdate, password: password, complete: { (status, error) in
                        
                    })
                }
                complete(userUpdate)
            case .failure:
                failure()
            }
            
        }
    }
    
    
//    public func remote(oldToken: String?, newToken: String, businessId: String) {
//        UserDefaultsManager.hasRegisteredRemote = false
//        DataManager.sharedInstance.registerForRemoteNotifications(oldToken: oldToken, newToken: newToken, businessId: businessId) { (status, error) in
//            if status {
//                UserDefaultsManager.hasRegisteredRemote = true
//            }
//        }
//    }
}
