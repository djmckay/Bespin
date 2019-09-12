//
//  BespinTokenViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import UIKit

fileprivate var inputTextTypes: [InputTextType]!

fileprivate var reuseIdentifier = "TokenCell"

class BespinTokenViewController: UITableViewController {
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = Auth.auth().currentUser
        self.title = "My Token"
        self.tableView.separatorStyle = .none
        self.tableView.register(InputTextWithLabelTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        inputTextTypes = [InputTextType(index: 0, placeholder: "Mailgun apiKey", contentType: nil, content: nil, required: true),
                          InputTextType(index: 2, placeholder: "Token ID", contentType: nil, content: nil, required: false, isEnabled: false)]
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextWithLabelTableViewCell
        
        cell.configure(inputTextType: inputTextTypes[indexPath.row])
        return cell
    }
    
    
    @IBAction func dismiss(sender: Any) {
        self.performSegue(withIdentifier: "TokenGenerated", sender: sender)
    }
    
    @IBAction func generateToken(sender: Any) {
        var key: String = ""
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
                key = cell.inputTextField.text!
            default:
                break
            }
        }
        let token = Token(token: key, user: DataManager.sharedInstance.currentUser!)
        BepsinActivityIndicator.show("Generating...", disableUI: false)
        TokensManager.sharedInstance.generateToken(token: token) { (token) in
            inputTextTypes = [InputTextType(index: 0, placeholder: "Mailgun apiKey", contentType: nil, content: token?.token, required: true),
                              InputTextType(index: 2, placeholder: "Token ID", contentType: nil, content: token?.userID.uuidString ?? "", required: true, isEnabled: false)]
            
            inputTextTypes.sort { (lhs, rhs) -> Bool in
                return lhs.index < rhs.index
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                    BepsinActivityIndicator.hide(true, animated: true)
                    self.dismiss(sender: self)

                })
            }
            
        }
    }
    
    
}
