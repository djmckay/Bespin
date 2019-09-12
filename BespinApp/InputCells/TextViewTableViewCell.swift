//
//  TextViewTableViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 11/28/18.
//

import UIKit

class TextViewTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textView: UITextView!
    static var nib = UINib(nibName: "TextViewTableViewCell", bundle: nil)
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String, label: String) {
        self.textView.text = text
        self.label.text = label
    }
    
}
