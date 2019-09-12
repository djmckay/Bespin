//
//  BespinUserViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit


fileprivate var reuseIdentifier = "UserCell"
fileprivate var reuseIdentifierButton = "UserButton"
class BespinUserViewController: UITableViewController {
    var user: User!
    fileprivate var buttonTypes: [ButtonType] = []
    fileprivate var inputTextTypes: [InputTextType]!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Info"
        self.tableView.separatorStyle = .none
        self.tableView.register(InputTextWithLabelTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(ButtonTableViewCell.nib, forCellReuseIdentifier: reuseIdentifierButton)
    }
    
    fileprivate func refresh() {
        inputTextTypes = [InputTextType(index: 0, placeholder: "Name", contentType: nil, content: user.name, required: true),
                          InputTextType(index: 1, placeholder: "Domain", contentType: nil, content: user.domain, required: true),
                          InputTextType(index: 2, placeholder: "Email", contentType: UITextContentType.emailAddress, content: user.username, required: true)]
        
        inputTextTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        buttonTypes = [ButtonType(index: 1, title: "Change Password", action: #selector(showPasswords), actionTarget: self),
                       ButtonType(index: 0, title: "Update", action: #selector(update), actionTarget: self)
        ]
        buttonTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        user = Auth.auth().currentUser
        refresh()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return inputTextTypes.count
        }
        return buttonTypes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            let inputCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextWithLabelTableViewCell
            
            inputCell.configure(inputTextType: inputTextTypes[indexPath.row])
            cell = inputCell
        }
        else {
            let button = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierButton, for: indexPath) as! ButtonTableViewCell
            button.configure(buttonType: buttonTypes[indexPath.row])
            cell = button
        }
        
        return cell
    }
    
    
    @IBAction func dismiss(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logout(sender: Any) {
        Auth.auth().signOut()
        self.dismiss(sender: sender)
    }
    
    @objc func update() {
        self.updateUserAction(self)
    }
    
    @objc func updatePassword() {
        self.updateUserAction(self, isPasswordUpdate: true)
    }
    
    func updateUserAction(_ sender: Any, isPasswordUpdate: Bool = false) {
        var name: String!
        var domain: String!
        var email: String!
        var password: String!
        var confirmPassword: String!
        
        for (index, inputTextType) in inputTextTypes.enumerated() {
            let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! InputTextWithLabelTableViewCell
            
            if inputTextType.required && !cell.inputTextField.hasText {
                cell.inputTextField.attributedPlaceholder = NSAttributedString(string: inputTextType.placeholder!, attributes: [NSAttributedString.Key("strokeColor") : UIColor.red])
                cell.inputLabel.textColor = UIColor.red
                BespinSimpleAlert.show("\(inputTextType.placeholder ?? "Field?") is required", disableUI: false)
                return

            } else {
                cell.inputLabel.textColor = UIColor.black
            }
            switch index {
            case 0:
                name = cell.inputTextField.text!
            case 1:
                domain = cell.inputTextField.text!
            case 2:
                email = cell.inputTextField.text!
            case 3:
                password = cell.inputTextField.text!
            case 4:
                confirmPassword = cell.inputTextField.text!
            default:
                break
            }
        }
        if password != confirmPassword {
            BespinSimpleAlert.show("Passwords must match", disableUI: false)
            return
        }
        user.name = name
        user.domain = domain
        user.username = email
        user.password = password
        
        BepsinActivityIndicator.show("Updating...", disableUI: false)
        NewUserManager.sharedInstance.update(user: user, isPasswordUpdate: isPasswordUpdate, complete: { (user) in
            BepsinActivityIndicator.hide(true, animated: true)
            self.user = user
            self.refresh()
        }) {
            let alert = UIAlertController(title: "Error", message: "Unable to update user", preferredStyle: UIAlertController.Style.alert)
            alert.popoverPresentationController?.sourceView = self.view
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: nil))
            DispatchQueue.main.async {
                BepsinActivityIndicator.hide(false, animated: true)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    
    @objc func showPasswords() {
        inputTextTypes.append(InputTextType(index: 3, placeholder: "New Password", contentType: UITextContentType.password, content: nil, required: true, isSecureTextEntry: true))
        inputTextTypes.append(InputTextType(index: 4, placeholder: "Confirm New Password", contentType: UITextContentType.password, content: nil, required: true, isSecureTextEntry: true))
        buttonTypes = [ButtonType(index: 0, title: "Update Password", action: #selector(updatePassword), actionTarget: self),
                       ButtonType(index: 1, title: "Cancel", action: #selector(removePasswords), actionTarget: self)
        ]
        buttonTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    @objc func removePasswords() {
        self.refresh()
    }
    
}
