//
//  DayHeatMap.swift
//  LoCalendar
//
//  Created by Drew Roberts on 5/16/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class DayHeatMap: UIView {
    let normalColor = ColorManager.normalColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    let backgColor = ColorManager.backgcolor
    
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
    
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    
    convenience init() {
        self.init(frame:CGRect.zero)
        self.backgroundColor = backgColor
        
        self.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.autoPinEdgesToSuperviewEdges()
        
        container.addSubview(dateContainer)
        dateContainer.autoPinEdgeToSuperviewEdge(.Left)
        dateContainer.autoPinEdgeToSuperviewEdge(.Top)
        dateContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        dateContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: container, withMultiplier: DayHeatMap.proportionOfDateContainer)
        
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}