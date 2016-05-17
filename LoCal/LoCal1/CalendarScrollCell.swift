//
//  CalendarScrollCell.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/15/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class CalendarScrollCell: UITableViewCell {
    
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor

    
    
    var container = UIView(forAutoLayout: ())
    var dateContainer = UIView(forAutoLayout: ())
    var dayName = UILabel(forAutoLayout: ())
    var dayDate = UILabel(forAutoLayout: ())
    var daySummaryContainer = UIView(forAutoLayout: ())
    
    var colorValues:[UIColor]?
    var addedViews = false
    var hourHeatMapViews = [UIView]()
    
    var day = Int()
    var month = Int()
    var year = Int()
    
    static let proportionOfDateContainer:CGFloat = 0.13
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = darkColor
        self.selectionStyle = .None
        self.layer.borderWidth = 0
        
        self.contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.autoPinEdgesToSuperviewEdges()
        
        container.addSubview(dateContainer)
        dateContainer.autoPinEdgeToSuperviewEdge(.Left)
        dateContainer.autoPinEdgeToSuperviewEdge(.Top)
        dateContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        dateContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: container, withMultiplier: CalendarScrollCell.proportionOfDateContainer)
        
        dateContainer.addSubview(dayName)
        dateContainer.addSubview(dayDate)
        dayName.textColor = UIColor.whiteColor()
        dayName.alpha = 0.4
        dayDate.textColor = UIColor.whiteColor()
        
        dayName.translatesAutoresizingMaskIntoConstraints = false
        dayDate.translatesAutoresizingMaskIntoConstraints = false
        
        dayName.autoPinEdge(.Top, toEdge: .Top, ofView: dateContainer)
        dayName.autoPinEdge(.Left, toEdge: .Left, ofView: dateContainer)
        dayName.autoPinEdge(.Right, toEdge: .Right, ofView:dateContainer)
        dayName.autoPinEdge(.Bottom, toEdge: .Top, ofView: dayDate)
        dayName.font = UIFont(name: dayName.font.fontName, size: 15)
        dayName.textAlignment = .Center
        
        dayDate.autoPinEdge(.Left, toEdge: .Left, ofView: dateContainer)
        dayDate.autoPinEdge(.Right, toEdge: .Right, ofView: dateContainer)
        dayDate.font = UIFont(name: dayDate.font.fontName, size: 23)
        dayDate.textAlignment = .Center
        
        container.addSubview(daySummaryContainer)
        daySummaryContainer.autoPinEdgeToSuperviewEdge(.Top)
        daySummaryContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        daySummaryContainer.autoPinEdgeToSuperviewEdge(.Right)
        daySummaryContainer.autoPinEdge(.Left, toEdge: .Right, ofView: dateContainer)
        
        //add views for heat map
        for _ in 0...23{
            let hourCell = UIView()
            hourCell.layer.borderWidth = 0.5
            hourCell.layer.borderColor = darkColor.CGColor
            self.hourHeatMapViews.append(hourCell)
        }
    }
    
    func setHeatMap(){
        var index = 0
        var first = true

        for hourCell in self.hourHeatMapViews{
            UIView.animateWithDuration(0.5, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                self.daySummaryContainer.addSubview(hourCell)
                self.setHeatMapHour(hourCell, index: index)
                
//                    let hourLabel = UILabel()
//                    hourCell.addSubview(hourLabel)
////                    hourLabel.autoCenterInSuperview()
////                    hourLabel.textAlignment = .Center
////                    hourLabel.autoPinEdgesToSuperviewEdges()
//                    hourLabel.textColor = UIColor.whiteColor()
//                    hourLabel.font = hourLabel.font.fontWithSize(10)
//                    
//                    if first{
//                        hourLabel.text = "12"
//                    }else if(index < 13){
//                        hourLabel.text = "\(index)"
//                    }else{
//                        hourLabel.text = "\(index - 12)"
//                    }
//                
//                self.hourHeatMapLabels.append(hourLabel)
//                hourLabel.hidden = true
                
                index += 1
                first = false
                
                }, completion: { (complete: Bool) in
            })
        }
        self.constrainHourViews()
        self.addedViews = true
        self.setNeedsDisplay()
    }
    
    func setHeatMapHour(hourCell:UIView, index:Int){
            let xPos = CGFloat(index)*(self.daySummaryContainer.frame.width/24)
            hourCell.frame = CGRectMake(xPos, 0, self.daySummaryContainer.frame.width/24,self.frame.height)
                if let colorVals = self.colorValues{
                    if colorVals.count >= index{
                        hourCell.backgroundColor = colorValues![index]
                    }
                }
    }
    
    func updateHeatMap(){
        if self.colorValues?.count == 24{
            var index = 0
            for hour in self.hourHeatMapViews{
                hour.backgroundColor = self.colorValues![index]
                index += 1
            }
        }
    }
    
    func constrainHourViews(){
        var first = true
        var prevHour:UIView?
        for hour in self.hourHeatMapViews{
            if(first){
                hour.autoPinEdge(.Left, toEdge: .Left, ofView: self.daySummaryContainer)
                hour.autoPinEdge(.Top, toEdge: .Top, ofView: self.daySummaryContainer)
                hour.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.daySummaryContainer)
                hour.autoMatchDimension(.Width, toDimension: .Width, ofView: self.daySummaryContainer, withMultiplier: 1/24)
                first = false
            }else{
                hour.autoPinEdge(.Left, toEdge: .Right, ofView: prevHour!)
                hour.autoPinEdge(.Top, toEdge: .Top, ofView: prevHour!)
                hour.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: prevHour!)
                hour.autoMatchDimension(.Width, toDimension: .Width, ofView: self.daySummaryContainer, withMultiplier: 1/24)
            }
            prevHour = hour
        }
    }
    
    func cellWasSelected(){
        var currentHour = 0
        for hour in self.hourHeatMapViews{
            UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                    hour.backgroundColor = self.darkColor
                }, completion: { (value:Bool) in
            })
        }
        
        for hour in self.hourHeatMapViews{
            UIView.animateWithDuration(0.2, delay: 0.2, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                hour.backgroundColor = self.colorValues![currentHour]
                currentHour += 1
                }, completion: { (value:Bool) in
            })
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func getDate() -> String{
        return "\(self.month)-\(self.day)-\(self.year)"
    }

//    func seeDayEvents(sender: UITapGestureRecognizer? = nil){
//        let dayEventsViewController = DayEventsViewController()
//        self.window?.rootViewController?.presentViewController(dayEventsViewController, animated: true, completion: nil)
//    }
}