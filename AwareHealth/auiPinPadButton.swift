//
//  auiPinPadButton.swift
//  AwareHealth
//
//  Created by Tom Tupper on 3/1/18.
//  Copyright © 2018 Awarepoint Inc. All rights reserved.
//

import UIKit
@IBDesignable

class auiPinPadButton: UIButton {
    var highlightColor: CGColor? = nil
    var standardColor: CGColor? = nil
    var bColorA: CGColor? = nil
    var bColorB: CGColor? = nil
    var tapped: Bool = false
    let impactGenerator = UIImpactFeedbackGenerator(style: .light)
    
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
            bColorA = UIColor.white.withAlphaComponent(0.30).cgColor
            bColorB = UIColor.white.withAlphaComponent(1).cgColor
            
        }
        
    }
    
    @IBInspectable var bBackgroundColor: UIColor = UIColor.clear {
        didSet {
            self.layer.backgroundColor = bBackgroundColor.cgColor
            standardColor = bBackgroundColor.cgColor
            
        }
        
    }
    
    @IBInspectable var bHighlightColor: UIColor = UIColor.clear {
        didSet {
            highlightColor = bHighlightColor.cgColor
            
        }
        
    }
    
    override var isHighlighted: Bool {
        didSet {
            if(isHighlighted) {
                touchedIn()
                
            } else {
                touchedOut()
                
            }
            
        }
        
    }
    
    private func touchedIn() {
        self.layer.backgroundColor = highlightColor
        self.layer.borderColor = bColorA
        if !tapped { impactGenerator.impactOccurred() }
        tapped = true
        
    }
    
    private func touchedOut() {
        self.layer.backgroundColor = standardColor
        self.layer.borderColor = bColorB
        tapped = false
        
    }

}
