//
//  auiPinPadBullet.swift
//  AwareHealth
//
//  Created by Tom Tupper on 3/2/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit

class auiPinPadBullet: UIButton {
    var bulletValue: String = ""
    var bulletIsFilled: Bool = false
    var bgSelectedColor: CGColor? = nil
    var bgStandardColor: CGColor? = nil
    var borderHighlightColor: CGColor? = nil
    var borderStandardColor: CGColor? = nil
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            
        }
        
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
            
        }
        
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
            borderStandardColor = UIColor.white.withAlphaComponent(0.16).cgColor
            borderHighlightColor = UIColor.white.withAlphaComponent(1).cgColor
            
        }
        
    }
    
    @IBInspectable var bBackgroundColor: UIColor = UIColor.clear {
        didSet {
            self.layer.backgroundColor = bBackgroundColor.cgColor
            borderStandardColor = bBackgroundColor.cgColor
            
        }
        
    }
    
    @IBInspectable var bHighlightColor: UIColor = UIColor.clear {
        didSet {
            borderHighlightColor = bHighlightColor.cgColor
            
        }
        
    }
    
    func setValue(bValue: String) {
        bulletValue = bValue
        
    }
    
    func setSelected() {
        bulletIsFilled = true
        self.layer.backgroundColor = UIColor.white.withAlphaComponent(0.16).cgColor
        
    }
    
    func setUnselected() {
        bulletIsFilled = false
        self.layer.backgroundColor = UIColor.clear.cgColor
        
    }
    
}
