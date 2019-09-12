//
//  LoginManager.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import Foundation

enum LoginResult {
    case success(User)
    case failure(AuthError)
}

public class LoginManager {
    
    static var sharedInstance = LoginManager()
    var login_session:String = ""
    
    func getUser() -> User? {
        return Auth.auth().currentUser
    }
    
    func login(username: String, password: String, complete: @escaping ((LoginResult) -> ())) {
        Auth.auth().signIn(withEmail: username, password: password) { (result) in
            switch result {
                
            case .success(let user):
                UserDefaultsManager.hasCreatedAuthUser = true
                user.getIDToken(completion: { (token, error) in
                    UserDefaultsManager.session = token
                })
                complete(LoginResult.success(user))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }
    
    func createUser(username: String, password: String, complete: @escaping ((_ status: Bool, _ error: Error?) -> ())) {
        if UserDefaultsManager.hasCreatedAuthUser {
            complete(UserDefaultsManager.hasCreatedAuthUser, nil)
            return
        }
        Auth.auth().createUser(withEmail: username, password: password) { (user, error) in
            if let error = error {
                complete(UserDefaultsManager.hasCreatedAuthUser, error)
            }
            else {
                UserDefaultsManager.hasCreatedAuthUser = true
                complete(UserDefaultsManager.hasCreatedAuthUser, nil)
            }
        }
    }
    
    func logout(complete: @escaping ((_ status: Bool, _ error: Error?) -> ())) {
            Auth.auth().signOut()
            complete(true, nil)
        
    }
    
    func pwReset(username: String, complete: @escaping ((_ status: Bool, _ error: Error?) -> ())) {
        Auth.auth().sendPasswordReset(withEmail: username) { (error) in
            if let error = error {
                complete(false, error)
            }
            else {
                complete(true, nil)
            }
        }
    }
    
    func newPassword(user: User, password: String, complete: @escaping ((_ status: Bool, _ error: Error?) -> ())) {
        Auth.auth().newPassword(user: user, password: password, complete: complete)
    }
    
    func checkSession(complete: @escaping ((_ status: Bool, _ error: Error?) -> ())) {
        if Auth.auth().currentUser != nil {
            complete(true, nil)
        } else {
            complete(false, nil)
        }
    }
    
    /*
     func login(username: String, password: String, loginDone: @escaping ((_ status: Bool, _ error: Error?) -> ()))
     {
     var post_data: [String: Any] = [:]
     
     post_data["username"] = username
     post_data["password"] = password
     
     DataManager.sharedInstance.post(post_data, url: login_url) { (response, status, error) in
     if let error = error {
     loginDone(false, error)
     }
     if status == false {
     loginDone(status, error)
     }
     
     if let data_block = response["data"] as? NSDictionary
     {
     if let session_data = data_block["session"] as? String
     {
     self.login_session = session_data
     UserDefaults.session = session_data
     loginDone(true, nil)
     }
     }
     }
     
     }
     
     func checkSession(complete: @escaping ((_ status: Bool, _ error: Error?) -> ()))
     {
     var post_data: [String: Any] = [:]
     
     post_data["session"] = UserDefaults.session
     
     DataManager.sharedInstance.post(post_data, url: check_session_url) { (response, status, error) in
     if let error = error {
     complete(false, error)
     }
     if status == false {
     complete(status, error)
     }
     if let responseCode = response["response_code"] as? Int {
     if responseCode == 200 {
     complete(true, nil)
     } else {
     complete(false, nil)
     }
     }
     
     }
     
     } */
}


