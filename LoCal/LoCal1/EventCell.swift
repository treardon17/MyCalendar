//
//  EventCell.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 5/16/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class EventCell: UITableViewCell{
    
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    //var timer:NSTimer? = nil
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = darkColor
        //timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("yourMethodToCall"), userInfo: nil, repeats: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}