//
//  EventCell.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 5/16/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class NormalEventCell: UITableViewCell{
    
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    //var timer:NSTimer? = nil
    var startTimeLabel = UILabel()
    var endTimeLabel = UILabel()
    var eventTitle = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = darkColor
        //timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("yourMethodToCall"), userInfo: nil, repeats: true)
        
        //time container
        let timeContainer = UIView()
        self.contentView.addSubview(timeContainer)
        timeContainer.autoPinEdgeToSuperviewEdge(.Left)
        timeContainer.autoPinEdgeToSuperviewEdge(.Top)
        timeContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        timeContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 1/6)
        
        //start time label
        timeContainer.addSubview(startTimeLabel)
        startTimeLabel.autoPinEdgeToSuperviewEdge(.Left)
        startTimeLabel.autoPinEdgeToSuperviewEdge(.Right)
        startTimeLabel.autoPinEdgeToSuperviewEdge(.Top)
        startTimeLabel.textColor = UIColor.whiteColor()
        startTimeLabel.font = UIFont(name: startTimeLabel.font.fontName, size: 12)
        
        //end time label
        timeContainer.addSubview(endTimeLabel)
        endTimeLabel.autoPinEdgeToSuperviewEdge(.Left)
        endTimeLabel.autoPinEdgeToSuperviewEdge(.Right)
        endTimeLabel.autoPinEdgeToSuperviewEdge(.Bottom)
        endTimeLabel.autoPinEdge(.Top, toEdge: .Bottom, ofView: startTimeLabel)
        endTimeLabel.autoMatchDimension(.Height, toDimension: .Height, ofView: self, withMultiplier: 0.5)
        endTimeLabel.textColor = UIColor.whiteColor()
        endTimeLabel.font = UIFont(name: endTimeLabel.font.fontName, size: 12)

        
        //event info container
        let eventInfoContainer = UIView()
        self.contentView.addSubview(eventInfoContainer)
        eventInfoContainer.autoPinEdge(.Left, toEdge: .Right, ofView: timeContainer)
        eventInfoContainer.autoPinEdgeToSuperviewEdge(.Top)
        eventInfoContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        eventInfoContainer.autoPinEdgeToSuperviewEdge(.Right)
        
        //event title
        eventInfoContainer.addSubview(eventTitle)
        eventTitle.autoPinEdge(.Left, toEdge: .Left, ofView: eventInfoContainer, withOffset: 15)
        eventTitle.autoPinEdgeToSuperviewEdge(.Top)
        eventTitle.autoPinEdgeToSuperviewEdge(.Bottom)
        eventTitle.autoPinEdgeToSuperviewEdge(.Right)
        eventTitle.textColor = UIColor.whiteColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}