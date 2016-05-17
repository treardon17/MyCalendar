//
//  TwoButtonOnBottom.swift
//  LoCal
//
//  Created by Tyler Reardon on 3/11/16.
//  Copyright © 2016 Skysoft. All rights reserved.
//

import Foundation

class TwoButtonsOnBottom: UIView{
    
    var leftButton : UIButton = UIButton()
    var rightButton : UIButton = UIButton()
    let buttonHeight : CGFloat = 40
    let sidebColor = UIColor(red: 24/255, green: 26/255, blue: 33/255, alpha: 1)
    let backgColor = UIColor(red: 42/255, green: 44/255, blue: 54/255, alpha: 1)
    var buttonConstraint : NSLayoutConstraint?
    var parentView : UIView?
    
    init(parentView: UIView, leftButtonText: String, rightButtonText: String){
        super.init(frame: CGRect.zero)
        self.parentView = parentView
        registerForKeyboardNotifications()
        
        self.addSubview(leftButton)
        self.addSubview(rightButton)

        self.autoSetDimension(.Height, toSize: buttonHeight)
                
        leftButton.setTitle(leftButtonText, forState: UIControlState.Normal)
        rightButton.setTitle(rightButtonText, forState: UIControlState.Normal)
        
        leftButton.autoPinEdge(.Top, toEdge: .Top, ofView: self)
        leftButton.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        buttonConstraint = leftButton.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
        leftButton.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.5)
        leftButton.backgroundColor = sidebColor
        leftButton.layer.borderWidth = 1
        leftButton.layer.borderColor = .None
    
        rightButton.setTitle(rightButtonText, forState: UIControlState.Normal)
        rightButton.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        rightButton.autoPinEdge(.Left, toEdge: .Right, ofView: leftButton)
        rightButton.autoPinEdge(.Top, toEdge: .Top, ofView: leftButton)
        rightButton.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: leftButton)
        rightButton.backgroundColor = sidebColor
        rightButton.layer.borderWidth = 1
        rightButton.layer.borderColor = .None
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func keyboardWasShown(notification: NSNotification) {
        var info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        self.buttonConstraint!.constant = -keyboardFrame.size.height
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.parentView!.setNeedsLayout()
            self.parentView!.layoutIfNeeded()
            }, completion: { finished in
        })
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.buttonConstraint!.constant = 0
        })
    }
    
    func registerForKeyboardNotifications(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: "UIKeyboardDidShowNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: "UIKeyboardWillHideNotification", object: nil)
    }
    
    
}