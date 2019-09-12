//
//  AttachmentCollectionViewCell.swift
//  BespinApp
//
//  Created by DJ McKay on 7/3/19.
//

import UIKit

class AttachmentCollectionViewCell: UICollectionViewCell {
    
    static let nib = UINib(nibName: "AttachmentCollectionViewCell", bundle: nil)
    static var defaultSize: CGSize {
        get {
            return CGSize(width:240, height:50)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    var attachment: Template.Attachment?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    func configure(attachment: Template.Attachment) {
        self.attachment = attachment
        self.nameLabel.text = attachment.filename
        layer.cornerRadius = layer.bounds.size.height / 4
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        
        let collectionViewBackgroundView = UIView()
        let gradientLayer = CAGradientLayer()
        gradientLayer.cornerRadius = layer.bounds.size.height / 4
        gradientLayer.masksToBounds = true
        gradientLayer.frame.size = frame.size
        // Start and end for left to right gradient
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        let colors = [UIColor.black.withAlphaComponent(0.3).cgColor, UIColor.white.withAlphaComponent(0.3).cgColor, UIColor.black.withAlphaComponent(0.3).cgColor]
        gradientLayer.colors = colors
        let locations: [NSNumber] = [0, 0.5, 1]
        gradientLayer.locations = locations
        self.backgroundView = collectionViewBackgroundView
        self.backgroundView?.layer.addSublayer(gradientLayer)
        
    }
}
