//
//  UserViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit


class InputTextType {
    var index: Int = 0
    var placeholder: String?
    var label: String?
    var contentType: UITextContentType?
    var content: String?
    var required: Bool = false
    var isSecureTextEntry: Bool = false
    var isEnabled: Bool = true
    var action: Selector?
    var actionTarget: Any?
    var actionEvent: UIControl.Event
    
    init(index: Int, placeholder: String, label: String? = nil, contentType: UITextContentType?, content: String?, required: Bool, isSecureTextEntry: Bool = false, isEnabled: Bool = true, action: Selector? = nil, actionTarget: Any? = nil, actionEvent: UIControl.Event = UIControl.Event.editingChanged) {
        self.index = index
        self.placeholder = placeholder
        self.contentType = contentType
        self.content = content
        self.required = required
        self.isSecureTextEntry = isSecureTextEntry
        self.isEnabled = isEnabled
        self.action = action
        self.actionTarget = actionTarget
        self.actionEvent = actionEvent
        self.label = label
    }
}

fileprivate var inputTextTypes: [InputTextType]!

fileprivate var reuseIdentifier = "RegisterCell"

class UserViewController: UITableViewController {
    
    var username: String!
    var password: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create New User"
        self.tableView.separatorStyle = .none
        self.tableView.register(InputTextTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        inputTextTypes = [InputTextType(index: 0, placeholder: "Name", contentType: nil, content: nil, required: true),
                          InputTextType(index: 1, placeholder: "Domain", contentType: nil, content: nil, required: true),
                          InputTextType(index: 2, placeholder: "Email", contentType: UITextContentType.emailAddress, content: username, required: true),
                          InputTextType(index: 3, placeholder: "Password", contentType: UITextContentType.password, content: password, required: true, isSecureTextEntry: true),
                          InputTextType(index: 4, placeholder: "Confirm Password", contentType: UITextContentType.password, content: nil, required: true, isSecureTextEntry: true)]
        
        inputTextTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return inputTextTypes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextTableViewCell
        
        cell.configure(inputTextType: inputTextTypes[indexPath.row])
        return cell
    }
    
    @IBAction func registerUserAction(_ sender: Any) {
        var name: String!
        var domain: String!
        var email: String!
        var confirmPassword: String!
        
        for (index, inputTextType) in inputTextTypes.enumerated() {
            let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! InputTextTableViewCell
            
            if inputTextType.required && !cell.inputTextField.hasText {
                cell.inputTextField.attributedPlaceholder = NSAttributedString(string: inputTextType.placeholder!, attributes: [NSAttributedString.Key("strokeColor") : UIColor.red])
                BespinSimpleAlert.show("\(inputTextType.placeholder ?? "Field?") is required", disableUI: false)
                return
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
        
        let user = User(name: name, domain: domain, username: email, password: password)
        BepsinActivityIndicator.show("Registering...", disableUI: false)
        NewUserManager.sharedInstance.create(user: user) { (status, error, auth) in
            if status {
                BepsinActivityIndicator.hide(true, animated: true)
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.popoverPresentationController?.sourceView = self.view
                if (auth) {
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: { (action) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                } else {
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: nil))
                }
                DispatchQueue.main.async {
                    BepsinActivityIndicator.hide(false, animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        
    }
    
    @IBAction func dismiss(sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
