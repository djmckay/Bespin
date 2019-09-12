//
//  InputTextWithLabelTableViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

class InputTextWithLabelTableViewCell: UITableViewCell {

    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    static var nib = UINib(nibName: "InputTextWithLabelTableViewCell", bundle: nil)
    
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
        if let label = inputTextType.label {
            self.inputLabel.text = label
        } else {
            self.inputLabel.text = inputTextType.placeholder
        }
        self.inputTextField.text = inputTextType.content
        self.inputTextField.textContentType = inputTextType.contentType
        self.inputTextField.isSecureTextEntry = inputTextType.isSecureTextEntry
        self.inputTextField.isEnabled = inputTextType.isEnabled
        inputTextField.removeTarget(nil, action: nil, for: .allEvents)
        if let action = inputTextType.action {
            inputTextField.addTarget(inputTextType.actionTarget, action: action, for: inputTextType.actionEvent)
        }
    }
    
}
