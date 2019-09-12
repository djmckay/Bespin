//
//  BespinMessageViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/27/18.
//

import UIKit

fileprivate var reuseIdentifier = "MessageCell"
fileprivate var reuseIdentifierButton = "MessageButton"
fileprivate var reuseIdentifierText = "MessageTextCell"

class BespinMessageViewController: UITableViewController {
    var testToken: Token!
    var message: Message? {
        didSet {
            //configureView()
        }
    }
    var template: Template?
    var templates: [Template] = []
    fileprivate var inputTextTypes: [InputTextType] = []
    fileprivate var buttonTypes: [ButtonType] = []
    var newFlag: Bool = false
    let formatter = DateFormatter()
    var testMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Send Message"
        self.tableView.separatorStyle = .none
        self.tableView.register(InputTextWithLabelTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(ButtonTableViewCell.nib, forCellReuseIdentifier: reuseIdentifierButton)
        self.tableView.register(TextViewTableViewCell.nib, forCellReuseIdentifier: reuseIdentifierText)
        
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
    }
    
    fileprivate func configureView() {
        
        inputTextTypes = [InputTextType(index: 0, placeholder: "Template", contentType: nil, content: template?.name, required: true, action: #selector(findTemplate), actionTarget: self, actionEvent: UIControl.Event.editingDidBegin),
                          InputTextType(index: 1, placeholder: "Subject", contentType: nil, content: template?.subject, required: true, action: #selector(updateMessage), actionTarget: self),
                          InputTextType(index: 2, placeholder: "From", contentType: nil, content: template?.from, required: true, action: #selector(updateMessage), actionTarget: self),
                          InputTextType(index: 3, placeholder: "To", contentType: nil, content: nil, required: true, action: #selector(updateMessage), actionTarget: self),
                          InputTextType(index: 4, placeholder: "Cc", contentType: nil, content: nil, required: true, action: #selector(updateMessage), actionTarget: self),
                          InputTextType(index: 5, placeholder: "Bcc", contentType: nil, content: nil, required: true, action: #selector(updateMessage), actionTarget: self),
                          InputTextType(index: 6, placeholder: "{\"email\":{\"variable1\":\"custom text\",\"variable2\":\"custom text 2\"}}", label: "Recipient Variables", contentType: nil, content: nil, required: true, action: #selector(updateMessage), actionTarget: self),
                          InputTextType(index: 7, placeholder: formatter.string(from: Date().addingTimeInterval(60.0*5)), label: "Delivery Time", contentType: nil, content: nil, required: true, action: #selector(showCalendar), actionTarget: self, actionEvent: UIControl.Event.editingDidBegin),
                            ]
        
        inputTextTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        
        buttonTypes = [ButtonType(index: 0, title: "Add Attachment", action: #selector(addAttachments(sender:)), actionTarget: self),
            ButtonType(index: 0, title: "Send Email", action: #selector(sendEmail), actionTarget: self),
                       ButtonType(index: 0, title: "Test Mode", action: #selector(toggleTestMode), actionTarget: self)
                       
        ]
        
        buttonTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        self.tableView.reloadData()
        message = Message()

        updateMessage()
//        StringPickerPopover(title: "Select Quantity", choices: qtyArray.map({ (item) -> String in
//            return item.description
//        }))
//            .setSelectedRow(invoiceData.quantity)
//            .setValueChange(action: { (popover, row, selectedString) in
//                self.invoiceDataQuantity.text = selectedString
//                self.invoiceData.quantity = row
//            })
//            .setDoneButton(action: { (popover, selectedRow, selectedString) in
//                self.invoiceDataQuantity.text = selectedString
//                self.invoiceData.quantity = selectedRow
//            })
//            .setCancelButton(action: { (_, _, _) in print("cancel")}
//            )
//            .appear(originView: invoiceDataQuantity, baseViewController: self.controller)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func toggleTestMode(sender: UIButton) {
        self.testMode = !self.testMode
        sender.backgroundColor = self.testMode ? UIColor(red: 0.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0) : UIColor.red
        sender.setTitle(self.testMode ? "Test Mode" : "Live Mode", for: .normal)
        self.updateMessage()
        
    }
    @objc func sendEmail() {
        print("email")
        BepsinActivityIndicator.show("Sending...", disableUI: false)
        let tokenRequest = TokenRequest(token: testToken)
        tokenRequest.message(message: self.message!) { (result) in
            switch result {
                
            case .success( _):
                DispatchQueue.main.async {
                    BepsinActivityIndicator.hide(true, animated: true)
                }
            case .failure(let error):
                
                let alert = UIAlertController(title: "Error", message: error.reason, preferredStyle: UIAlertController.Style.alert)
                alert.popoverPresentationController?.sourceView = self.view
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: nil))
                DispatchQueue.main.async {
                    BepsinActivityIndicator.hide(false, animated: true)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
        }
    }
    
    @objc func showCalendar() {
        let cell = self.tableView.cellForRow(at: IndexPath(row: 7, section: 0)) as! InputTextWithLabelTableViewCell
        let popover = DatePickerPopover(title: "Delivery Time").setDoneButton(title: "✔︎", font: nil, color: UIColor(red: 68/255, green: 118/255, blue: 4/255, alpha: 1.0)) { (_, selectedDate) in
            print(selectedDate)
            
        }.setDateMode(UIDatePicker.Mode.dateAndTime)
            .setClearButton(title: "✘", font: nil, color: UIColor(red: 255/255, green: 75/255, blue: 56/255, alpha: 1.0)) { (_, _) in
                cell.inputTextField.text = nil
                self.updateMessage()
            }.setValueChange { (_, selectedDate) in
                cell.inputTextField.text = self.formatter.string(from: selectedDate)
                self.updateMessage()
        }.setMinuteInterval(5)
        
        DispatchQueue.main.async {
            popover.appear(originView: cell, baseViewController: self)
        }
        
    }
    
    @objc func findTemplate() {
        guard !templates.isEmpty else {
            BespinSimpleAlert.show("No templates found, try again", disableUI: false)
            return
        }
        let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! InputTextWithLabelTableViewCell

        StringPickerPopover(title: "Select Template", choices: templates.map({ (item) -> String in
            return item.name
        }))
            //.setSelectedRow(invoiceData.quantity)
            .setValueChange(action: { (popover, row, selectedString) in
                cell.inputTextField.text = self.templates[row].id?.uuidString ?? "Problem"
                self.updateMessage()
                
            })
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                cell.inputTextField.text = self.templates[selectedRow].id?.uuidString ?? "Problem"
                self.updateMessage()
            })
            .setCancelButton(action: { (_, _, _) in print("cancel")}
            )
            .appear(originView: cell, baseViewController: self)
        
    }
    
    @objc func updateMessage() {
        print("updateMessage")
        

        for (index, _) in inputTextTypes.enumerated() {
            let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! InputTextWithLabelTableViewCell
            switch index {
            case 0:
                if let input = cell.inputTextField.text, input.isEmpty {
                    message?.template = nil
                } else {
                    message?.template = cell.inputTextField.text
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 0
                }) {
                    input.content = message?.template
                }
                
            case 1:
                if let input = cell.inputTextField.text, !input.isEmpty {
                    message?.subject = input
                } else {
                    message?.subject = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 1
                }) {
                    input.content = message?.subject
                }
            case 2:
                if let input = cell.inputTextField.text, !input.isEmpty {
                    message?.from = Message.Address(email: input)
                } else {
                    message?.from = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 2
                }) {
                    input.content = cell.inputTextField.text
                }
            case 3:
                if let input = cell.inputTextField.text, !input.isEmpty {
                    let inputs = input.split(separator: ",")
                    message?.to = []
                    for email in inputs {
                        message?.to?.append(Message.Address(email: String(email)))
                    }
                    
                } else {
                    message?.to = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 3
                }) {
                    input.content = cell.inputTextField.text
                }
            case 4:
                if let input = cell.inputTextField.text, !input.isEmpty {
                    let inputs = input.split(separator: ",")
                    message?.cc = []
                    for email in inputs {
                        message?.cc?.append(Message.Address(email: String(email)))
                    }
                } else {
                    message?.cc = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 4
                }) {
                    input.content = cell.inputTextField.text
                }
            case 5:
                if let input = cell.inputTextField.text, !input.isEmpty {
                    let inputs = input.split(separator: ",")
                    message?.bcc = []
                    for email in inputs {
                        message?.bcc?.append(Message.Address(email: String(email)))
                    }
                } else {
                    message?.bcc = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 5
                }) {
                    input.content = cell.inputTextField.text
                }
            case 6:
                if let input = cell.inputTextField.text?.replacingOccurrences(of: "“", with: "\"").replacingOccurrences(of: "”", with: "\""), !input.isEmpty {
                    do {
                    message?.recipientVariables = try JSONDecoder().decode(Message.RecipientVariables.self, from: input.data(using: .utf8)!)
                    } catch {
                        print(error)
                    }
                } else {
                    message?.recipientVariables = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 6
                }) {
                    input.content = cell.inputTextField.text
                }
            case 7:
                if let input = cell.inputTextField.text, !input.isEmpty {
                    message?.deliveryTime = formatter.date(from: input)
                } else {
                    message?.deliveryTime = nil
                }
                if let input = inputTextTypes.first(where: { (texttype) -> Bool in
                    texttype.index == 7
                }) {
                    input.content = cell.inputTextField.text
                }
            default:
                break
            }
        }
        message?.testmode = self.testMode 
        if message?.template == nil {
            message?.text = "Test Message from Bespin"
        } else {
            message?.text = nil
        }
        self.tableView.reloadSections([2], with: .none)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return inputTextTypes.count
        }
        else if section == 1 {
            return buttonTypes.count
        }
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            let inputCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextWithLabelTableViewCell
            inputCell.configure(inputTextType: inputTextTypes[indexPath.row])
            cell = inputCell
        } else if indexPath.section == 1 {
            let button = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierButton, for: indexPath) as! ButtonTableViewCell
            button.configure(buttonType: buttonTypes[indexPath.row])
            cell = button
        } else {
            let textViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierText, for: indexPath) as! TextViewTableViewCell
            textViewCell.textView.delegate = self
            let encoder = JSONEncoder()
            //encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            do {
            let body = try encoder.encode(message)
                if let jsonString = String(data: body, encoding: .utf8) {
                    textViewCell.configure(text: jsonString, label: "JSON Data")
                }
            
            } catch {
                print(error)
            }
            cell = textViewCell
        }
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return (self.view.bounds.width * 0.66)
        }
        return tableView.rowHeight
    }
    
    @IBAction func dismiss(sender: Any) {
        DispatchQueue.main.async {
        }
        //self.dismiss(animated: true, completion: nil)
    }
    
}

extension BespinMessageViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        do {
        let resource = try JSONDecoder().decode(Message.self, from: textView.text.data(using: .utf8)!)
            message = resource
            for (index, _) in inputTextTypes.enumerated() {
                let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as! InputTextWithLabelTableViewCell
                switch index {
                case 0:
                    cell.inputTextField.text = message?.template
                case 1:
                    cell.inputTextField.text = message?.subject
                case 2:
                    cell.inputTextField.text = message?.from?.email
                case 3:
                    cell.inputTextField.text = message?.to?.stringArray.joined(separator: ", ")
                case 4:
                    cell.inputTextField.text = message?.cc?.stringArray.joined(separator: ", ")
                case 5:
                    cell.inputTextField.text = message?.bcc?.stringArray.joined(separator: ", ")
                case 6:
                    if let variables = message?.recipientVariables {
                        let encoder = JSONEncoder()
                        encoder.dateEncodingStrategy = .iso8601
//                        encoder.outputFormatting = .prettyPrinted
                        if let variableData = try? encoder.encode(variables) {
                            cell.inputTextField.text = String(data: variableData, encoding: .utf8)
                        }
                    }
                    
                case 7:
                    guard let date = message?.deliveryTime else { break }
                    cell.inputTextField.text = formatter.string(from: date)
                default:
                    break
                }
            }
            //self.tableView.reloadSections([0], with: .none)
        } catch {
            print(error)
        }
    }
}

extension BespinMessageViewController: UIDocumentPickerDelegate {
    
    @IBAction func addAttachments(sender: Any?) {
        var documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = documentPicker.popoverPresentationController!
        popover.sourceView = self.view
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        var emailAttachments = [Message.EmailAttachment]()
        for url in urls {
            print(url.lastPathComponent)
            print(url.pathExtension)
            if let data = try? Data(contentsOf: url) {
                let attachment = Message.EmailAttachment(data: data, filename: url.lastPathComponent)
                emailAttachments.append(attachment)
            }
        }
        message?.attachments = emailAttachments
        updateMessage()
    }
}
