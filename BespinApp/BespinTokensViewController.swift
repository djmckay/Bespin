//
//  BespinTokensViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

fileprivate var inputTextTypes: [InputTextType]!

fileprivate var reuseIdentifier = "TokenCell"

class BespinTokensViewController: UITableViewController {
    var tokens: [Token] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Tokens"
        self.tableView.register(InputTextWithLabelTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        refresh(nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl?) {
        BepsinActivityIndicator.show("Updating...", disableUI: false)
        TokensManager.sharedInstance.getTokens(user: DataManager.sharedInstance.currentUser!, complete: { (tokens) in
            self.tokens = tokens ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                BepsinActivityIndicator.hide(true, animated: true)
            }
        }) {
            BepsinActivityIndicator.hide(false, animated: true)
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
        return tokens.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextWithLabelTableViewCell
        
        cell.inputLabel.text = tokens[indexPath.row].token
        cell.inputTextField.text = tokens[indexPath.row].id?.uuidString
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if tokens[indexPath.row].id != nil {
            BepsinActivityIndicator.show("Deleting...", disableUI: false)
            TokensManager.sharedInstance.delete(token: tokens.first!, complete: {
                self.tokens.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    BepsinActivityIndicator.hide(true, animated: true)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            }) {
                print("handle error")
                BepsinActivityIndicator.hide(false, animated: true)
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "TestToken", sender: indexPath)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "TestToken" {
                if let vc = segue.destination as? BespinMessageViewController {
                    if let indexPath = sender as? IndexPath {
                        vc.testToken = tokens[indexPath.row]
                        TemplateManager.sharedInstance.getAll(token: vc.testToken, complete: { (templates) in
                            vc.templates = templates ?? []
                        }) {
                        
                        }
                    }
                    
                }
            }
        }
    }
    
    @IBAction func unwindFromGenerated(segue:UIStoryboardSegue) {
        
        DispatchQueue.main.async {
            self.refresh(nil)
        }
    }
    
    
}
