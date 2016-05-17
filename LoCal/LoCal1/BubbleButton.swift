//
//  BubbleButton.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 5/2/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class BubbleButton: NavButton {
    
    //a list of tuples --> .0 is the navButton, .1 is the layout constraints associated with that button
    var navButtons = [(NavButton,UIView,NSLayoutConstraint)]()
    var degrees:CGFloat = 135; //the value in degrees the button is rotated initially

    //var navButtons = [NavButton]()
    //var navButtonConstraints = [NavButton:[NSLayoutConstraint]]()
    
    convenience init(buttonColor:UIColor, imageFileName:String, identifier:String){
        self.init(buttonColor: buttonColor, imageFileName: imageFileName)
        self.addTarget(self, action: #selector(BubbleButton.onSelect(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func addNavButton(buttonColor:UIColor,imageFileName:String){
        
        let newNavButtonContainer = UIView()
        newNavButtonContainer.userInteractionEnabled = false
        self.addSubview(newNavButtonContainer)
        //self.superview?.addSubview(newNavButtonContainer)
        newNavButtonContainer.autoPinEdgesToSuperviewEdges()
        
        let newNavButton = NavButton(buttonColor: buttonColor, imageFileName: imageFileName)
        newNavButtonContainer.addSubview(newNavButton)
        newNavButton.userInteractionEnabled = true
        newNavButton.hidden = true
        newNavButton.alpha = 0
        
        let bottomConstraint = newNavButton.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: newNavButtonContainer)
        newNavButton.autoAlignAxisToSuperviewAxis(.Vertical)
        self.navButtons.append(newNavButton, newNavButtonContainer, bottomConstraint)

        self.degrees = 180
    }
    
    func onSelect(sender: UIButton!){
        if(self.navButtons.count > 0){
            if(!self.buttonTapped){
                self.showButtons()
            }else{
                UIView.animateWithDuration(0.33, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
                    self.hideButtons()
                    }, completion: { (value: Bool) in
                })
            }
        }
    }
    
    func showButtons(){
        self.buttonTapped = true
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: .CurveEaseIn, animations: {
                self.buttonImageView?.transform = CGAffineTransformMakeRotation(-45 * CGFloat(M_PI)/180) //turn the plus into an x
                let rotateBy:CGFloat = -90/(CGFloat(self.navButtons.count)+1)
                var currentRotation:CGFloat = 0
                for button in self.navButtons{
                    currentRotation += rotateBy
                    let relativeDegreesToRotate:CGFloat = (360 - currentRotation)                   //degrees to rotate the image view on the button
                    button.0.hidden = false                                                         //put the button into the view
                    button.0.alpha = 1                                                              //make the button visible
                    button.0.buttonImageView!.transform = CGAffineTransformMakeRotation(relativeDegreesToRotate * CGFloat(M_PI)/180) //make image vertical
                    button.1.transform = CGAffineTransformMakeRotation(currentRotation*CGFloat(M_PI)/180)  //rotate the container view
                    button.2.constant = -(CGFloat(self.navButtons.count))*self.navButtonSize  //how far the button is away from the origin
                }
            }, completion: {(value: Bool) in
        })
    }
    
    func hideButtons(){
        self.buttonTapped = false
        UIView.animateWithDuration(0.5, animations: {
            self.transform = CGAffineTransformIdentity //set back to original position
            self.buttonImageView!.transform = CGAffineTransformIdentity //set back to original position
        })
        for button in self.navButtons{
            UIView.animateWithDuration(0.3, delay: 0.15, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.7, options: .CurveEaseIn, animations: {
                for button in self.navButtons{
                    button.0.alpha = 0
                    button.1.transform = CGAffineTransformIdentity
                }
                }, completion: {(value: Bool) in
                    //button.0.hidden = true
            })
        }
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if(self.buttonTapped){
            for button in self.navButtons{
                if(CGRectContainsPoint(button.0.bounds, button.0.convertPoint(point, fromView: self))){
                    UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .CurveEaseIn, animations: {
                            button.0.transform = CGAffineTransformMakeScale(1.25, 1.25)
                        }, completion: {(value:Bool) in
                            UIView.animateWithDuration(0.2, animations: {
                                button.0.transform = CGAffineTransformIdentity
                            })
                    })
                    
                    if(button.0.alpha != 0){
                        //wait to hide the buttons until after the function has returned
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.5*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                            self.hideButtons()
                        })
                        return button.0
                    }
                }
            }
        }
        return super.hitTest(point, withEvent: event)
    }
    
}