//
//  BespinTemplateViewController.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import UIKit
import WebKit

class ButtonType {
    var index: Int = 0
    var title: String?
    var action: Selector?
    var isEnabled: Bool = true
    var actionTarget: Any?
    
    init(index: Int, title: String, action: Selector?, actionTarget: Any?, isEnabled: Bool = true) {
        self.index = index
        self.title = title
        self.action = action
        self.isEnabled = isEnabled
        self.actionTarget = actionTarget
    }
}

enum MessageSections: Int {
    case template = 0, attachmentButtons, attachments, bodyButtons
}

fileprivate var reuseIdentifier = "TemplateCell"
fileprivate var reuseIdentifierButton = "TemplateButton"
fileprivate var reuseIdentifierCollection = "CollectionCell"

class BespinTemplateViewController: UITableViewController {
    var template: Template? {
        didSet {
            configureView()
        }
    }
    var attachments: [Template.Attachment] = [] {
        didSet {
            //configureView()
        }
    }
    
    var attachmentsToDelete: [Template.Attachment] = [] {
        didSet {
            //configureView()
        }
    }
    
    var attachmentsNew: [Template.Attachment] = [] {
        didSet {
            //configureView()
        }
    }
    
    fileprivate var inputTextTypes: [InputTextType] = []
    fileprivate var buttonTypes: [ButtonType] = []
    fileprivate var attachmentButtons: [ButtonType] = []
    var newFlag: Bool = false
    lazy var attachmentDelegate = AttachmentCollectionDelegate(dataSource: self, reload: self.reloadAttachmentSection)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Template"
        self.tableView.separatorStyle = .none
        self.tableView.register(InputTextWithLabelTableViewCell.nib, forCellReuseIdentifier: reuseIdentifier)
        self.tableView.register(ButtonTableViewCell.nib, forCellReuseIdentifier: reuseIdentifierButton)
        self.tableView.register(CollectionViewTableViewCell.nib, forCellReuseIdentifier: reuseIdentifierCollection)
        if let template = self.template {
            TemplateAttachmentManager.sharedInstance.getAll(token: DataManager.sharedInstance.defaultToken!, template: template, complete: { (attachments) in
                self.attachments = attachments ?? []
                self.reloadAttachmentSection()
//                if let attachment = attachments?.first {
//                    let url = URL(dataRepresentation: attachment.data, relativeTo: nil)!
//                    DispatchQueue.main.async {
//                        let webView = WKWebView(frame: CGRect(x:20,y:20,width: self.view.frame.size.width-40, height: self.view.frame.size.height-40))
//                        webView.load(attachment.data, mimeType: "application/pdf", characterEncodingName:"", baseURL: url)
//                        self.view.addSubview(webView)
//                    }
                    
//                }
            }) {
                
            }
        }
        
        
        
    }
    
    fileprivate func configureView() {
        if let template = template {
            title = template.name
        } else {
            title = "New Template"
        }
        inputTextTypes = [InputTextType(index: 0, placeholder: "Name", contentType: nil, content: template?.name, required: true),
                          InputTextType(index: 1, placeholder: "Subject", contentType: nil, content: template?.subject, required: true),
                          InputTextType(index: 2, placeholder: "From", contentType: UITextContentType.emailAddress, content: template?.from, required: false),
                          InputTextType(index: 4, placeholder: "Bcc", contentType: UITextContentType.emailAddress, content: template?.bcc, required: false),
                          InputTextType(index: 5, placeholder: "Reply-to", contentType: UITextContentType.emailAddress, content: template?.replyTo, required: false),
                          //                          InputTextType(index: 6, placeholder: "Text", contentType: nil, content: nil, required: true),
            //                          InputTextType(index: 7, placeholder: "HTML", contentType: nil, content: nil, required: true),
            InputTextType(index: 3, placeholder: "Cc", contentType: UITextContentType.emailAddress, content: template?.cc, required: false)]
        
        inputTextTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        buttonTypes = [ButtonType(index: 1, title: "View HTML", action: #selector(viewHtml), actionTarget: self),
                       ButtonType(index: 0, title: "View Text", action: #selector(viewText), actionTarget: self)
        ]
        
        attachmentButtons = [ButtonType(index: 0, title: "Add Attachments", action: #selector(addAttachments(sender:)), actionTarget: self)]
        
        buttonTypes.sort { (lhs, rhs) -> Bool in
            return lhs.index < rhs.index
        }
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    enum EmailBody {
        case html(Template)
        case text(Template)
        
        public var body: String {
            switch self {
            
            case .html(let template):
                 return template.html
            case .text(let template):
                return template.text
            }
        }
    }
    
    var currentEmailBody: EmailBody?
    
    @objc func viewHtml() {
        print("html")
        guard let template = template else { return }
        self.currentEmailBody = EmailBody.html(template)
        performSegue(withIdentifier: "showEmailBody", sender: currentEmailBody)
    }
    
    @objc func viewText() {
        print("text")
        guard let template = template else { return }
        self.currentEmailBody = EmailBody.text(template)
        performSegue(withIdentifier: "showEmailBody", sender: currentEmailBody)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return inputTextTypes.count
        } else if section == 1 {
            return attachmentButtons.count
        } else if section == MessageSections.attachments.rawValue {
            return attachments.isEmpty ? 0 : 1
        }
        return buttonTypes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if indexPath.section == 0 {
            let inputCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! InputTextWithLabelTableViewCell
            inputCell.configure(inputTextType: inputTextTypes[indexPath.row])
            cell = inputCell
        } else if indexPath.section == MessageSections.attachmentButtons.rawValue {
            let button = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierButton, for: indexPath) as! ButtonTableViewCell
            button.configure(buttonType: attachmentButtons[indexPath.row])
            cell = button
        } else if indexPath.section == MessageSections.attachments.rawValue {
            let collection = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierCollection) as! CollectionViewTableViewCell
            collection.configure(data: attachmentDelegate)
            cell = collection
        } else {
            let button = tableView.dequeueReusableCell(withIdentifier: reuseIdentifierButton, for: indexPath) as! ButtonTableViewCell
            button.configure(buttonType: buttonTypes[indexPath.row])
            cell = button
        }
        return cell
    }
    
    
    @IBAction func dismiss(sender: Any) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "unwindFromSave", sender: sender)
        }
        //self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: Any) {
        if self.template == nil {
            self.template = Template(name: "", text: "", html: "", user: DataManager.sharedInstance.currentUser!)
        }
        guard var template = template else { return }
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
                template.name = cell.inputTextField.text!
            case 1:
                template.subject = cell.inputTextField.text!
            case 2:
                template.from = cell.inputTextField.text!
            case 3:
                template.cc = cell.inputTextField.text!
            case 4:
                template.bcc = cell.inputTextField.text!
            case 5:
                template.replyTo = cell.inputTextField.text!
            default:
                break
            }
        }
        if DataManager.sharedInstance.defaultToken == nil {
            BespinSimpleAlert.show("Token is required", disableUI: false)
            return
        }
        BepsinActivityIndicator.show("Saving...", disableUI: false)
        TemplateManager.sharedInstance.create(token: DataManager.sharedInstance.defaultToken!, template: template, complete: { (template) in
            DispatchQueue.main.async {
                BepsinActivityIndicator.hide(true, animated: true)
                let group = DispatchGroup()
                
                self.attachmentsNew.forEach({ (attachment) in
                    group.enter()
                    BepsinActivityIndicator.show("Saving Attachments...", disableUI: false)
                    TemplateAttachmentManager.sharedInstance.create(token: DataManager.sharedInstance.defaultToken!, attachment: attachment, complete: { (attachment) in
                        BepsinActivityIndicator.hide(false, animated: true)
                        group.leave()
                    }, failure: {
                        DispatchQueue.main.async {
                            BepsinActivityIndicator.hide(false, animated: true)
                            BespinSimpleAlert.show("Unable to Save Attachments", disableUI: false)
                        }
                        group.leave()
                    })
                })
                group.wait()
                
                self.attachmentsToDelete.forEach({ (attachment) in
                    group.enter()
                    BepsinActivityIndicator.show("Deleting Attachments...", disableUI: false)
                    TemplateAttachmentManager.sharedInstance.delete(token: DataManager.sharedInstance.defaultToken!, attachment: attachment, complete: {
                        BepsinActivityIndicator.hide(false, animated: true)
                        group.leave()
                    }, failure: {
                        DispatchQueue.main.async {
                            BepsinActivityIndicator.hide(false, animated: true)
                            BespinSimpleAlert.show("Unable to Delete Attachments", disableUI: false)
                        }
                        group.leave()
                    })
                })
                group.wait()
                self.dismiss(sender: sender)
            }
        }) {
            DispatchQueue.main.async {
                BepsinActivityIndicator.hide(false, animated: true)
                BespinSimpleAlert.show("Unable to Save", disableUI: false)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "showEmailBody" {
                if let vc = segue.destination as? BespinTemplateEmailBodyViewController {
                    if let emailType = sender as? EmailBody {
                        vc.emailBody = emailType
                        vc.title = template?.name
                    }
                }
                
            }
        }
    }
    
    var unwindFromText: String?
    
    @IBAction func unwindFromText(segue:UIStoryboardSegue) {
        switch currentEmailBody {
        
        case .none:
            break
        case .some(.html):
            self.template?.html = unwindFromText ?? ""
        case .some(.text):
            self.template?.text = unwindFromText ?? ""
        }
        print("unwindFromText")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == MessageSections.attachments.rawValue  {
            return AttachmentCollectionViewCell.defaultSize.height * (CGFloat(self.attachments.count ?? 0) / 2.0) + AttachmentCollectionViewCell.defaultSize.height
        }
        
        return  UITableView.automaticDimension
        
    }
    
}

extension BespinTemplateViewController: UIDocumentPickerDelegate {
    
    @IBAction func addAttachments(sender: Any?) {
        var documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = documentPicker.popoverPresentationController!
        popover.sourceView = self.view
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            print(url.lastPathComponent)
            print(url.pathExtension)
        }
        
        guard template != nil else { return }
        
        if attachments == nil {
            attachments = []
        }
        if attachmentsNew == nil {
            attachmentsNew = []
        }
        for url in urls {
            if let data = try? Data(contentsOf: url) {
                let attachment = Template.Attachment(filename: url.lastPathComponent, data: data, template: template!)
                attachmentsNew.append(attachment)
                attachments.append(attachment)
            }
            
        }
        
        //template.attachments.append(contentsOf: urls)
        
        self.reloadAttachmentSection()
        
    }
    func reloadAttachmentSection() {
        DispatchQueue.main.async {
            self.tableView.reloadSections([MessageSections.attachments.rawValue], with: .automatic)
        }
    }
}

protocol AttachmentDataSource {
    var attachments: [Template.Attachment] { get set }
    var attachmentsToDelete: [Template.Attachment] { get set }
    var attachmentsNew: [Template.Attachment] { get set }
}

class AttachmentCollectionDelegate: CollectionViewData {
    var reload: () -> ()
    var dataSource: AttachmentDataSource!
    
    //var attachments: [Template.Attachment] = []
    
    init(dataSource: AttachmentDataSource, reload: @escaping ()->()) {
        self.reload = reload
        self.dataSource = dataSource
    }
    
    func configureCell(cell: UICollectionViewCell, cellForItemAt indexPath: IndexPath) {
        if let attachmentCell = cell as? AttachmentCollectionViewCell {
            attachmentCell.configure(attachment: dataSource.attachments[indexPath.row])

        }
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        print(dataSource.attachments.count)
        return dataSource.attachments.count
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func registerCell(collectionView: UICollectionView) -> String {
        collectionView.register(AttachmentCollectionViewCell.nib, forCellWithReuseIdentifier: "attachmentCell")
        return "attachmentCell"
    }
    
    func didSelectCell(cell: UICollectionViewCell) {
        if let attachmentCell = cell as? AttachmentCollectionViewCell {
            
            if let attachment = attachmentCell.attachment {
                if attachment.id != nil {
                    dataSource.attachmentsToDelete.append(attachment)
                }
                dataSource.attachments.removeAll(where: { (file) -> Bool in
                    if attachment.id != nil {
                        return file.id == attachment.id
                    } else {
                        return file.filename == attachment.filename
                    }
                    
                    
                })
                DispatchQueue.main.async {
                    self.reload()
                }
            }
        }
    }
    
    func sizeForItemAt(indexPath: IndexPath) -> CGSize {
        return AttachmentCollectionViewCell.defaultSize
    }
    
    func backgroundColor() -> UIColor {
        return UIColor.clear
    }
    
}

extension BespinTemplateViewController: AttachmentDataSource {
//    var attachments: [Template.Attachment] {
//        get {
//            return attachments ?? []
//        }
//        set {
//            template?.attachments = newValue
//        }
//    }
    
    
}
