//
//  SummaryBubble.swift
//  LoCal
//
//  Created by Tyler Reardon on 5/18/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class SummaryBubble: UIView{
    
    var topLabel = UILabel()
    var valueLabel = UILabel()
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    convenience init(label:String, color:UIColor){
        self.init(frame: CGRect.zero)
        self.backgroundColor = color
        
        self.addSubview(topLabel)
        self.topLabel.text = label
        self.topLabel.textColor = UIColor.whiteColor()
        self.topLabel.textAlignment = .Center
        self.topLabel.autoPinEdgeToSuperviewEdge(.Top)
        self.topLabel.autoPinEdgeToSuperviewEdge(.Left)
        self.topLabel.autoPinEdgeToSuperviewEdge(.Right)

        self.addSubview(valueLabel)
        self.valueLabel.text = "0"
        self.valueLabel.textColor = UIColor.whiteColor()
        self.valueLabel.autoPinEdgeToSuperviewEdge(.Bottom)
        self.valueLabel.autoPinEdgeToSuperviewEdge(.Left)
        self.valueLabel.autoPinEdgeToSuperviewEdge(.Right)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Takes an integer value and sets the label of the value label
    func setValueLabelWithInt(number: Int){
        self.valueLabel.text = "\(number)"
    }
}
