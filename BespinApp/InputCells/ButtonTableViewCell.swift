//
//  ButtonTableViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 11/26/18.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    static var nib = UINib(nibName: "ButtonTableViewCell", bundle: nil)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(buttonType: ButtonType) {
        button.setTitle(buttonType.title, for: .normal)
        button.removeTarget(nil, action: nil, for: .allEvents)
        if let action = buttonType.action {
            button.addTarget(buttonType.actionTarget, action: action, for: UIControl.Event.touchUpInside)
        }
        
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        
    }
    
}
