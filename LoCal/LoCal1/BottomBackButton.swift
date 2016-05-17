//
//  BottomBackButton.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 5/16/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class BottomBackButton: UIView{
    
    override init(frame: CGRect){
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(buttonText: String){
        self.init(frame: CGRect.zero)
    }
    
    
}