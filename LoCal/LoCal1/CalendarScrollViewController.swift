//
//  CalendarScrollViewController.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/14/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation
import UIKit

class CalendarScrollViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    let calendarManager = CalendarManager()
    let calendarContainerHeightMultiplyer = 0.35
    var calendarContainer = UIView()
    
    var hourViewContainerContainer = UIView()
    var hourViewContainer = UIView()
    var hourViewLabels = [UILabel]()
    
    var dayTable = DayTable(forAutoLayout: ())
    var dayCellHeight = CGFloat()
    var bubbleButton:BubbleButton?
    
    let todayButton = UIButton()
    var forwardMonth = UIButton()
    var backwardMonth = UIButton()
    var calendarView = CalendarView()
    var currentHighlightedButtons = [CalendarViewDateButton]()
    var currentDay = Int()
    
    var currentDaysInView = [NSIndexPath()]
    var dayCellMap = [String:Int]() //holds the row index for the different dates stored, with key mm-dd-yyyy format
    var cellCache = NSCache() //caches the scrollview cells
    var threadQueue = NSOperationQueue()
    var viewFirstLoaded = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.threadQueue.maxConcurrentOperationCount = 7
        dayCellMap = calendarManager.fillDateMap()
        cellCache.countLimit = 120 // cache up to four months worth of data
        cellCache.evictsObjectsWithDiscardedContent = true
        
        //update calendarView every 60 seconds
        let date = NSDate()
        let components = calendarManager.calendar.components([.NSDayCalendarUnit, .NSHourCalendarUnit , .NSMinuteCalendarUnit , .NSSecondCalendarUnit], fromDate: date)
//        let currentHour = components.hour
//        let currentMinute = components.minute
        self.currentDay = components.day
        let second = components.second
        let beginTimerAfter = 60 - second
        //Begin the timer on the minute (for accuracy)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(beginTimerAfter)*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            //update the calendar info every 60 seconds
            NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(CalendarScrollViewController.updateCalendarOnDateChange), userInfo: nil, repeats: true)
        })
        //end update
                
        self.view.addSubview(calendarContainer)
        self.calendarContainer.autoPinEdge(.Top, toEdge: .Top, ofView: self.view)
        self.calendarContainer.autoPinEdge(.Left, toEdge: .Left, ofView: self.view)
        self.calendarContainer.autoPinEdge(.Right, toEdge: .Right, ofView: self.view)
        self.calendarContainer.autoMatchDimension(.Height, toDimension: .Height, ofView: self.view, withMultiplier: CGFloat(CalendarView.calendarContainerHeightMultiplyer))
        self.calendarContainer.backgroundColor = darkColor
        
        self.calendarContainer.addSubview(calendarView)
        //self.calendarView.autoCenterInSuperview()
        self.calendarView.autoPinEdgeToSuperviewEdge(.Top)
        self.calendarView.autoMatchDimension(.Width, toDimension: .Width, ofView: calendarContainer)
        self.calendarView.forwardMonth.addTarget(self, action: #selector(CalendarScrollViewController.goForwardOneMonth(_:)), forControlEvents: .TouchUpInside)
        self.calendarView.backwardMonth.addTarget(self, action: #selector(CalendarScrollViewController.goBackwardOneMonth(_:)), forControlEvents: .TouchUpInside)
        
        self.calendarContainer.addSubview(todayButton)
        self.todayButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: calendarView)
        self.todayButton.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: calendarContainer)
        self.todayButton.autoMatchDimension(.Width, toDimension: .Width, ofView: calendarContainer)
        self.todayButton.autoSetDimension(.Height, toSize: 40)
        self.todayButton.setTitle("Today", forState: .Normal)
        self.todayButton.addTarget(self, action: #selector(CalendarScrollViewController.todayButtonTap(_:)), forControlEvents: .TouchUpInside)
        
        //SET UP HOUR LABELS
        self.view.addSubview(hourViewContainerContainer)
        self.hourViewContainerContainer.backgroundColor = darkColor
        hourViewContainerContainer.autoPinEdgeToSuperviewEdge(.Left)
        hourViewContainerContainer.autoPinEdgeToSuperviewEdge(.Right)
        hourViewContainerContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: calendarContainer)
        self.hourViewContainerContainer.addSubview(self.hourViewContainer)
        self.hourViewContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: hourViewContainerContainer, withMultiplier: (1-CalendarScrollCell.proportionOfDateContainer))
        self.hourViewContainer.autoPinEdgeToSuperviewEdge(.Top)
        self.hourViewContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        self.hourViewContainer.autoPinEdgeToSuperviewEdge(.Right)
        var prevHour:UILabel?
        for hour in 0...23{
            let hourLabel = UILabel()
            self.hourViewContainer.addSubview(hourLabel)
            hourLabel.autoPinEdgeToSuperviewEdge(.Top)
            hourLabel.autoPinEdgeToSuperviewEdge(.Bottom)
            hourLabel.autoMatchDimension(.Width, toDimension: .Width, ofView: self.hourViewContainer, withMultiplier: 1/24)
            hourLabel.textAlignment = .Center
            hourLabel.textColor = UIColor.whiteColor()
            hourLabel.font = hourLabel.font.fontWithSize(10)
//            hourLabel.transform = CGAffineTransformMakeRotation(-90*CGFloat(M_PI)/180)  //rotate the label 90 degrees
            
            if hour == 0{
                hourLabel.text = "12"
            }else if(hour < 13){
                hourLabel.text = "\(hour)"
            }else{
                hourLabel.text = "\(hour - 12)"
            }
            
            if hour == 0{
                hourLabel.autoPinEdgeToSuperviewEdge(.Left)
            }else{
                hourLabel.autoPinEdge(.Left, toEdge: .Right, ofView: prevHour!)
            }
            hourLabel.alpha = 0.25
            prevHour = hourLabel
            self.hourViewLabels.append(hourLabel)
        }
        //END HOUR LABEL SET UP
        
        //SET UP DAY TABLE
        self.view.addSubview(dayTable)
        dayTable.backgroundColor = lightDarkColor
        dayTable.autoPinEdge(.Top, toEdge: .Bottom, ofView: hourViewContainerContainer)
        dayTable.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.view)
        dayTable.autoPinEdge(.Left, toEdge: .Left, ofView: self.view)
        dayTable.autoPinEdge(.Right, toEdge: .Right, ofView: self.view)
        dayTable.dataSource = self;
        dayTable.delegate = self;
        dayTable.registerClass(CalendarScrollCell.self, forCellReuseIdentifier: "CalendarScrollCell")
        dayTable.showsVerticalScrollIndicator = false
        dayTable.showsHorizontalScrollIndicator = false
        dayTable.separatorColor = UIColor.clearColor()
        dayTable.separatorStyle = .None
        dayTable.separatorEffect = .None
        //END SET UP DAY TABLE
        
        calendarView.addActionToDateButtons(self, action: #selector(CalendarScrollViewController.onDateButtonTap(_:)))
        self.highlightCurrentDaysInView()
        
        self.bubbleButton = BubbleButton(buttonColor: blueColor, imageFileName: "AddEventButtonPlus.png", identifier: "Menu")
        self.view.addSubview(bubbleButton!)
        self.bubbleButton?.autoPinEdge(.Right, toEdge: .Right, ofView: self.view, withOffset: -7)
        self.bubbleButton?.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.view, withOffset: -7)
        
        bubbleButton?.addNavButton(greenColor, imageFileName: "AddLocation.png")
        bubbleButton?.addNavButton(blueColor, imageFileName: "AddLocation.png")
        bubbleButton?.addNavButton(darkColor, imageFileName: "AddLocation.png")
//        bubbleButton?.addNavButton(lightDarkColor, imageFileName: "AddLocation.png")
//        bubbleButton?.addNavButton(whiteColor, imageFileName: "AddLocation.png")
        
        bubbleButton?.navButtons[0].0.addTarget(self, action: #selector(CalendarScrollViewController.addLocation(_:)), forControlEvents: .TouchUpInside)
        bubbleButton?.navButtons[1].0.addTarget(self, action: #selector(CalendarScrollViewController.addEvent(_:)), forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        dayCellHeight = self.dayTable.frame.height/7
        if let indices = dayTable.indexPathsForVisibleRows {
            self.currentDaysInView.removeAll()
            self.currentDaysInView = indices
            self.highlightCurrentDaysInView()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.viewFirstLoaded{
            let indexPath = NSIndexPath(forItem: dayCellMap[calendarManager.getCurrentDateString()]!, inSection: 0)
            self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
            self.viewFirstLoaded = false
        }
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    func highlightCurrentDaysInView(){
        
        for highlightedButton in self.currentHighlightedButtons{
            if(highlightedButton.status != CalendarViewDateButton.SelectionStatus.PrevMonth
                && highlightedButton.status != CalendarViewDateButton.SelectionStatus.NextMonth
                && highlightedButton.status != CalendarViewDateButton.SelectionStatus.CurrentDay){
                
                highlightedButton.setViewStatus(CalendarViewDateButton.SelectionStatus.Normal)
            }
        }
        
        currentHighlightedButtons.removeAll()
        
        if let indices = dayTable.indexPathsForVisibleRows {
            self.currentDaysInView.removeAll()
            self.currentDaysInView = indices
        
        
            for dayInView in self.currentDaysInView{
                if let tableCell = dayTable.cellForRowAtIndexPath(dayInView) as? CalendarScrollCell{
                    let startDay = calendarView.getStartDayInMonth(calendarView.modifiedMonth, year: calendarView.modifiedYear)
                    let date = calendarView.dateContainers[startDay + tableCell.day - 1] //zero based index for day of the month in dateContainers
                    if(tableCell.day == date.day && tableCell.month == date.month && tableCell.year == date.year){
                        date.setViewStatus(CalendarViewDateButton.SelectionStatus.CurrentlyDisplayedItem)
                        date.setNeedsDisplay()
                        date.setNeedsLayout()
                        self.currentHighlightedButtons.append(date)
                    }
                }
            }
            
            //make sure the right amount of cells are highlighted
            if(self.currentDaysInView.count > 7
                && self.currentHighlightedButtons.count > 0
                && self.currentHighlightedButtons.last?.day > 15
                || self.currentHighlightedButtons.count > 7){
                    self.currentHighlightedButtons[0].setViewStatus(CalendarViewDateButton.SelectionStatus.Normal)
                    self.currentHighlightedButtons.removeFirst()
            }
        }
    }
    
    func changeMonthBasedOnScrollDirectionAndTopCell(cell: CalendarScrollCell){
        if(cell.day < 15
            && (cell.month == calendarView.modifiedMonth + 1
                || cell.year == calendarView.modifiedYear + 1
                && cell.month == 1)
            && dayTable.dayTableScrollDirection == DayTable.ScrollDirections.Down
            && dayTable.scrolling){
            //calendarView.goForwardOneMonth()
            calendarView.goToDate(cell.month, day: cell.day, year: cell.year)
        }else if(cell.day >= 15
            && (cell.month == calendarView.modifiedMonth - 1
                || cell.year == calendarView.modifiedYear - 1
                && cell.month == 12)
            && dayTable.dayTableScrollDirection == DayTable.ScrollDirections.Up
            && dayTable.scrolling){
            //calendarView.goBackwardOneMonth()
            calendarView.goToDate(cell.month, day: cell.day, year: cell.year)
        }
    }
    
    func goToTheRightDate(){
        if(self.currentHighlightedButtons.count < 7 && self.currentDaysInView.count > 1){
            if(self.currentDaysInView.count > 7){
                if let topCellInView = dayTable.cellForRowAtIndexPath(self.currentDaysInView[1]) as? CalendarScrollCell{
                    if(topCellInView.day == 1 || self.currentHighlightedButtons.count == 0 || topCellInView.month != calendarView.modifiedMonth){
                        self.calendarView.goToDate(topCellInView.month, day: topCellInView.day, year: topCellInView.year)
                    }
                }
            }else{
                if let topCellInView = dayTable.cellForRowAtIndexPath(self.currentDaysInView[0]) as? CalendarScrollCell{
                    if( topCellInView.day == 1  || self.currentHighlightedButtons.count == 0 || topCellInView.month != calendarView.modifiedMonth){
                        self.calendarView.goToDate(topCellInView.month, day: topCellInView.day, year: topCellInView.year)
                    }
                }
            }
        }
    }
    
    func autoShowCompleteCell(scrollView: UIScrollView){
        if let dayTable = scrollView as? DayTable{
            if dayTable.dayTableScrollDirection == DayTable.ScrollDirections.Up{
                if let first = self.currentDaysInView.first{
                    dayTable.scrollToRowAtIndexPath(first, atScrollPosition: .Top, animated: true)
                }
            }else if dayTable.dayTableScrollDirection == DayTable.ScrollDirections.Down{
                if let last = self.currentDaysInView.last{
                    dayTable.scrollToRowAtIndexPath(last, atScrollPosition: .None, animated: true)
                }
            }
        }
        self.highlightCurrentDaysInView()
    }
    
    //TABLE VIEW FUNCTIONS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.calendarManager.numberOfDaysLoaded
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
            let scrollDirection = dayTable.panGestureRecognizer.velocityInView(dayTable).y
            if scrollDirection != 0{
                dayTable.getScrollDirection(scrollDirection)
            }
            if let indices = dayTable.indexPathsForVisibleRows {
                self.currentDaysInView.removeAll()
                self.currentDaysInView = indices
            }
            if(self.currentHighlightedButtons.count < 7 || self.currentHighlightedButtons.count == 0){
                if(self.currentHighlightedButtons.count < 7 || self.currentDaysInView.count > 7){
                    if let cell = dayTable.cellForRowAtIndexPath(self.currentDaysInView[0]) as? CalendarScrollCell{
                        self.changeMonthBasedOnScrollDirectionAndTopCell(cell)
                    }
                }else if (self.currentDaysInView.count <= 7 && (self.currentHighlightedButtons.count < 7 || self.currentDaysInView.count > 0)){
                    if let cell = dayTable.cellForRowAtIndexPath(self.currentDaysInView.first!) as? CalendarScrollCell{
                        self.changeMonthBasedOnScrollDirectionAndTopCell(cell)
                    }
                }
            }
        self.goToTheRightDate()
        self.highlightCurrentDaysInView()
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return dayCellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var taskToExecute:()->()
        var dayCell:CalendarScrollCell?
        if let cell = self.cellCache.objectForKey(indexPath){
            dayCell = (cell as? CalendarScrollCell)!
            
            taskToExecute = { () -> Void in
                let date = self.calendarManager.makeNSDateFromComponents(dayCell!.month, day: dayCell!.day, year: dayCell!.year)
                let events = self.calendarManager.getEventsForDate(date)
                dayCell!.colorValues?.removeAll()
                dayCell!.colorValues = self.calendarManager.getColorValuesForHours(events)
                dispatch_async(dispatch_get_main_queue()) {
                    UIView.animateWithDuration(0.5, animations: {
                        if(!(dayCell!.addedViews)){
                            dayCell!.setHeatMap()
                        }
                        dayCell!.updateHeatMap()
                    })
                }
            }
            if self.threadQueue.operationCount > 20{
                self.threadQueue.cancelAllOperations()
            }
            self.threadQueue.addOperationWithBlock(taskToExecute)
        }else{
            dayCell = CalendarScrollCell()
            self.cellCache.setObject(dayCell!, forKey: indexPath)
            
            taskToExecute = { () -> Void in
                let date = self.calendarManager.makeNSDateFromComponents(dayCell!.month, day: dayCell!.day, year: dayCell!.year)
                let events = self.calendarManager.getEventsForDate(date)
                dayCell!.colorValues?.removeAll()
                dayCell!.colorValues = self.calendarManager.getColorValuesForHours(events)
                dispatch_async(dispatch_get_main_queue()) {
                    UIView.animateWithDuration(0.5, animations: {
                        dayCell!.setHeatMap()
                    })
                }
            }
            if self.threadQueue.operationCount > 20{
                self.threadQueue.cancelAllOperations()
            }
            self.threadQueue.addOperationWithBlock(taskToExecute)
        }
        
        let currentDayRowIndex = self.dayCellMap[self.calendarManager.getCurrentDateString()]
        let dateTuple = self.calendarManager.getDateFromCurrentDateWithOffset(indexPath.row - currentDayRowIndex!)
        dayCell!.dayDate.text = "\(dateTuple.1)"
        dayCell!.month = dateTuple.0
        dayCell!.day = dateTuple.1
        dayCell!.year = dateTuple.2
        let dayName = self.calendarManager.getDayString(self.calendarManager.getDayOfWeek(dayCell!.getDate()))
        dayCell!.dayName.text = dayName

        return dayCell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let dayCell = tableView.cellForRowAtIndexPath(indexPath) as? CalendarScrollCell

        UIView.animateWithDuration(0.5, animations: {
            dayCell?.cellWasSelected()
        }) { (value:Bool) in
            self.presentViewController(DayEventsViewController(month: (dayCell?.month)!,day: (dayCell?.day)!, year: (dayCell?.year)!), animated: true, completion: {})
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        self.autoShowCompleteCell(scrollView)
        self.dayTable.scrolling = false
        self.dayTable.systemScrolling = false
        goToTheRightDate()
        highlightCurrentDaysInView()
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool){
        if(!decelerate){
            self.autoShowCompleteCell(scrollView)
        }
        //goToTheRightDate()
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dayTable.scrolling = true
    }
    //END TABLE VIEW FUNCTIONS///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    //CALENDAR FUNCTIONS
    
    func updateCalendarOnDateChange(){
        calendarView.updateMonth(calendarView.currentMonth, year: calendarView.currentYear)
        let oldDateTuple = calendarManager.getDateFromCurrentDateWithOffset(-1)
        let oldIndexPath = NSIndexPath(forItem: self.dayCellMap[calendarManager.getDateString(oldDateTuple.0,day: oldDateTuple.1, year: oldDateTuple.2)]!, inSection: 0)
        let dayCell = dayTable.cellForRowAtIndexPath(oldIndexPath) as? CalendarScrollCell

        if(self.currentDay != calendarManager.currentDay &&
            dayCell?.month == calendarManager.currentMonth &&
            dayCell?.day == calendarManager.currentDay &&
            dayCell?.year == calendarManager.currentYear){
            
            //scroll to the current date if the topmost scroll cell was the previous day
            let currentIndexPath = NSIndexPath(forItem: self.dayCellMap[calendarManager.getCurrentDateString()]!, inSection: 0)
            self.dayTable.scrollToRowAtIndexPath(currentIndexPath, atScrollPosition: .Top, animated: true)
        }else{
            self.highlightCurrentDaysInView()
        }
    }
    
    func todayButtonTap(sender:UIButton!){
        dayTable.setContentOffset(dayTable.contentOffset, animated: false)
        let indexPath = NSIndexPath(forItem: dayCellMap[calendarManager.getCurrentDateString()]!, inSection: 0)
        
        if(self.currentHighlightedButtons.count > 0 && self.currentHighlightedButtons.first?.month == calendarManager.currentMonth
            && self.currentHighlightedButtons.first?.year == calendarManager.currentYear){
            self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }else{
            self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
            self.calendarView.goToDate(calendarManager.currentMonth, day: calendarManager.currentDay, year: calendarManager.currentYear)
        }
    }
    
    func onDateButtonTap(sender:UIButton!){
        if let date = sender as? CalendarViewDateButton{
            print(date.getDate())
            let indexPath = NSIndexPath(forItem: dayCellMap[date.getDate()]!, inSection: 0)
            
            if(date.status != CalendarViewDateButton.SelectionStatus.PrevMonth
                && date.status != CalendarViewDateButton.SelectionStatus.NextMonth){
                self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }else{
                self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
            }
            
            if(date.status == CalendarViewDateButton.SelectionStatus.PrevMonth){
                self.calendarView.goToDate(date.month, day: date.day, year: date.year)
            }else if(date.status == CalendarViewDateButton.SelectionStatus.NextMonth){
                self.calendarView.goToDate(date.month, day: date.day, year: date.year)
            }
        }
        dayTable.systemScrolling = true
    }

    func goForwardOneMonth(sender:UIButton!){
        dayTable.setContentOffset(dayTable.contentOffset, animated: false) //stop any previous scrolling actions
        dayTable.dayTableScrollDirection = DayTable.ScrollDirections.None //set scroll action to none so it doesn't confuse the auto-alignment of cells
        let indexPath = NSIndexPath(forItem: dayCellMap[calendarView.getModifiedDateStartOfMonth()]!, inSection: 0)         //create the index path
        self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)                            //go to the right cell
        self.dayTable.systemScrolling = false
        self.highlightCurrentDaysInView()                                                                                   //highlight the right cells
    }
    
    func goBackwardOneMonth(sender:UIButton!){
        dayTable.setContentOffset(dayTable.contentOffset, animated: false)
        dayTable.dayTableScrollDirection = DayTable.ScrollDirections.None
        let indexPath = NSIndexPath(forItem: dayCellMap[calendarView.getModifiedDateStartOfMonth()]!, inSection: 0)
        self.dayTable.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        dayTable.systemScrolling = false
    }
    
    func addLocation(sender: UIButton!){
        self.presentViewController(AddLocationViewController(), animated: true, completion: {})
    }
    
    func addEvent(sender: UIButton!){
        self.presentViewController(AddEventViewController(), animated: true, completion: {})
    }
}