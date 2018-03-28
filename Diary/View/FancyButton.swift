//
//  FancyButton.swift
//  Diary
//
//  Created by 牛苒 on 2018/3/28.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit

@IBDesignable
class FancyButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .black {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
}
