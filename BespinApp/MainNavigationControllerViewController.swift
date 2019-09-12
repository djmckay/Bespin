//
//  MainNavigationControllerViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

class MainNavigationControllerViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isLoggedIn() {
            perform(#selector(presentBespinController), with: nil, afterDelay: 0.01)
        } else {
            perform(#selector(presentLoginController), with: nil, afterDelay: 0.01)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func isLoggedIn() -> Bool {
        return UserDefaultsManager.isLoggedIn && Auth.auth().checkUser() 
    }
    
    
    @objc func presentLoginController() {
        let loginController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "LoginController") as! LoginViewController
        present(loginController, animated: true, completion: nil)
    }
    
    @objc func presentBespinController() {
        let bespinController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "BespinController")
        present(bespinController, animated: true, completion: nil)
    }
    
    

}
