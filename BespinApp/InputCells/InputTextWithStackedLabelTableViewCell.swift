//
//  InputTextWithStackedLabelTableViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 7/7/19.
//

import UIKit

class InputTextWithStackedLabelTableViewCell: UITableViewCell {

    static var nib = UINib(nibName: "InputTextWithStackedLabelTableViewCell", bundle: nil)
    
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
