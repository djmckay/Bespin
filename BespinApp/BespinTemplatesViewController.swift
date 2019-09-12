//
//  BespinTemplatesViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import UIKit

fileprivate var reuseIdentifier = "TemplateCell"

class BespinTemplatesViewController: UITableViewController {
    var templates: [Template] = []
    var token: Token { get {
        return DataManager.sharedInstance.defaultToken!
        }
    }
    var user = DataManager.sharedInstance.currentUser!
    fileprivate var inputTextTypes: [InputTextType]!
    var detailViewController: BespinTemplateViewController? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Templates"
        self.tableView.register(InputTextWithStackedLabelTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        navigationItem.leftBarButtonItem = editButtonItem
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh(_:)))
        navigationItem.rightBarButtonItems = [refreshButton, addButton]
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? BespinTemplateViewController
        }
        refresh(nil)

        
    }
    
    @objc
    func insertNewObject(_ sender: Any) {
        if let selectedRow = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: selectedRow, animated: true)
        }
        
        self.performSegue(withIdentifier: "showNewDetail", sender: sender)
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl?) {
        //TokensManager.sharedInstance.getTokens(user: DataManager.sharedInstance.currentUser!) { (tokens) in
        //    self.tokens = tokens ?? []
            if let token = DataManager.sharedInstance.defaultToken {
                BepsinActivityIndicator.show("Updating...", disableUI: false)
                TemplateManager.sharedInstance.getAll(token: token, complete: { (templates) in
                    self.templates = templates ?? []
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        BepsinActivityIndicator.hide(true, animated: true)
                    }
                }, failure: {
                    print("problem")
                    DispatchQueue.main.async {
                        BepsinActivityIndicator.hide(false, animated: true)
                    }
                })
            } else {
                BespinSimpleAlert.show("Must setup a token first", disableUI: false)
        }
            

            
        //}
        
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
        return templates.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextWithStackedLabelTableViewCell
        
        cell.inputLabel.text = templates[indexPath.row].name
        cell.inputTextField.text = templates[indexPath.row].id?.uuidString
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDetail", sender: indexPath)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if let indexPath = sender as? IndexPath {
                if identifier == "ShowTemplate" {
                    let vc = segue.destination as! BespinTemplateViewController
                    vc.template = templates[indexPath.row]
                }
            }
            if identifier == "NewTemplate" {
                let vc = segue.destination as! BespinTemplateViewController
                vc.template = Template(name: "", text: "", html: "", user: user)
                vc.newFlag = true
            }
        }
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = templates[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! BespinTemplateViewController
                controller.template = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
        if segue.identifier == "showNewDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! BespinTemplateViewController
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
            controller.template = Template(name: "", text: "", html: "", user: user)
        }
    }
    
    @IBAction func unwindFromSave(segue:UIStoryboardSegue) {
        
        DispatchQueue.main.async {
            self.refresh(nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if templates[indexPath.row].id != nil {
            BepsinActivityIndicator.show("Deleting...", disableUI: false)
            TemplateManager.sharedInstance.delete(token: token, template: templates[indexPath.row], complete: {
                self.templates.remove(at: indexPath.row)
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
    
}


