//
//  UIColorExtension.swift
//  BespinApp
//
//  Created by DJ McKay on 11/25/18.
//

import UIKit

extension UIColor {
    
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
}
