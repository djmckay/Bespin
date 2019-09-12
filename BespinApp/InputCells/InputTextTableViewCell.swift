//
//  InputTextTableViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

class InputTextTableViewCell: UITableViewCell {

    @IBOutlet weak var inputTextField: UITextField!
    
    static var nib = UINib(nibName: "InputTextTableViewCell", bundle: nil)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(inputTextType: InputTextType) {
        self.inputTextField.placeholder = inputTextType.placeholder
        self.inputTextField.text = inputTextType.content
        self.inputTextField.textContentType = inputTextType.contentType
        self.inputTextField.isSecureTextEntry = inputTextType.isSecureTextEntry
        self.inputTextField.isEnabled = inputTextType.isEnabled
    }
    
}
