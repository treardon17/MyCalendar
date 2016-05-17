//
//  NavButton.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 5/1/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class NavButton: UIButton {
    
    let eventView = UIView()
    let addEventButton = UIButton()
    var imageFileName = String()
    
    var buttonColor = UIColor.whiteColor()
    var navButtonSize : CGFloat = 50
    var navButtonImageSize : CGFloat = 25
    var navButtonBorderWidth : CGFloat = 2
    var navButtonBorderColor = UIColor.whiteColor()
    var buttonWidth = NSLayoutConstraint()
    var buttonHeight = NSLayoutConstraint()
    var sizeRatio : CGFloat = CGFloat()
    var buttonTapped = false
    var buttonImageView:UIImageView?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init (buttonColor: UIColor, imageFileName: String) {
        self.init(frame:CGRect.zero)
        self.buttonColor = buttonColor
        self.imageFileName = imageFileName
        customInitialization()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func customInitialization(){
        buttonHeight = self.autoSetDimension(.Height, toSize: navButtonSize)
        buttonWidth = self.autoMatchDimension(.Width, toDimension: .Height, ofView: self)
        
        self.backgroundColor = buttonColor
        self.layer.cornerRadius = navButtonSize/2
        self.layer.borderWidth = 2
        self.layer.borderColor = navButtonBorderColor.CGColor
        self.userInteractionEnabled = true
        
        let buttonImage = UIImage(named: imageFileName)
        buttonImageView = UIImageView(image: buttonImage)
        self.sizeRatio = (buttonImage?.size.width)!/(buttonImage?.size.height)!
        
        self.addSubview(buttonImageView!)
        buttonImageView!.autoSetDimension(.Height, toSize: navButtonImageSize)
        buttonImageView!.autoMatchDimension(.Width, toDimension: .Height, ofView: buttonImageView!, withMultiplier: self.sizeRatio)
        buttonImageView!.autoCenterInSuperview()
    }
    
    
}