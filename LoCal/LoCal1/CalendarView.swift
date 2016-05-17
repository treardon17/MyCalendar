//
//  CalendarView.swift
//  
//
//  Created by Tyler Reardon on 4/14/16.
//
//

import Foundation

class CalendarView: UIView{
    
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    static let calendarContainerHeightMultiplyer = 0.35
    
    var monthName = String()
    var dayNames:[String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    var daysInMonth = Int()
    let dayHeight:CGFloat = 30.0
    
    var monthLabel = UILabel()
    var yearLabel = UILabel()
    var dayLabels:[UILabel] = []
    var dateContainers: [CalendarViewDateButton] = []
    var daysInView: [CalendarViewDateButton] = []
    
    var currentDay = Int()
    var currentMonth = Int()
    var currentYear = Int()
    
    var modifiedDay = Int()
    var modifiedMonth = Int()
    var modifiedYear = Int()
    
    let allInfoContainer = UIView()
    let calendarContainer = UIView()
    var forwardMonth = UIButton()
    var backwardMonth = UIButton()
    
    var monthLabelHeightConstraint:NSLayoutConstraint?
    var yearLabelHeightConstraint:NSLayoutConstraint?
    var dayOfWeekHeightConstraints = [NSLayoutConstraint]()
    var dayHeightConstraints = [NSLayoutConstraint]()
    
    let calendarManager = CalendarManager()
    var timer:NSTimer? = nil
    var currentHour = Int()
    var currentMinute = Int()
    
    convenience init(){
        self.init(frame: CGRect.zero)
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.NSHourCalendarUnit , .NSMinuteCalendarUnit , .NSSecondCalendarUnit], fromDate: date)

        self.currentHour = components.hour
        self.currentMinute = components.minute
        let second = components.second
        
        let beginTimerAfter = 60 - second
        //Begin the timer on the minute (for accuracy)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(beginTimerAfter)*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.updateDateInfo()
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(CalendarManager.updateDateInfo), userInfo: nil, repeats: true)
        })
        
        self.addSubview(allInfoContainer)
        allInfoContainer.autoPinEdgeToSuperviewEdge(.Top)
        allInfoContainer.autoPinEdgeToSuperviewEdge(.Bottom)
        allInfoContainer.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.75)
        allInfoContainer.autoAlignAxisToSuperviewAxis(.Vertical)
        
        //set month day label
        allInfoContainer.addSubview(monthLabel)
        monthLabel.autoPinEdge(.Top, toEdge: .Top, ofView: allInfoContainer)
        monthLabel.autoPinEdge(.Left, toEdge: .Left, ofView: allInfoContainer)
        monthLabelHeightConstraint = monthLabel.autoMatchDimension(.Height, toDimension: .Height, ofView: allInfoContainer, withMultiplier: 1/8)
        monthLabel.textColor = UIColor.whiteColor()
        monthLabel.textAlignment = .Right
        monthLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 16.0)
        monthLabel.textColor = greenColor
        
        self.addSubview(yearLabel)
        yearLabel.autoPinEdge(.Top, toEdge: .Top, ofView: monthLabel)
        yearLabelHeightConstraint = yearLabel.autoMatchDimension(.Height, toDimension: .Height, ofView: allInfoContainer, withMultiplier: 1/8)
        yearLabel.autoPinEdge(.Right, toEdge: .Right, ofView: allInfoContainer)
        yearLabel.textColor = UIColor.whiteColor()
        yearLabel.textAlignment = .Left
        
        //set days of the week
        for day in dayNames{
            let dayName = UILabel()
            dayName.text = day
            dayLabels.append(dayName)
        }
        
        allInfoContainer.addSubview(calendarContainer)
        calendarContainer.autoPinEdgeToSuperviewEdge(.Left)
        calendarContainer.autoPinEdgeToSuperviewEdge(.Right)
        calendarContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: monthLabel)
        calendarContainer.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: allInfoContainer)
        
        var prevDayOfWeek:UIView?
        var first = true
        for day in dayLabels{
            
            day.textAlignment = .Center
            day.font = day.font.fontWithSize(12)
            day.textColor = UIColor.whiteColor()
            
            calendarContainer.addSubview(day)
            day.autoPinEdge(.Top, toEdge: .Bottom, ofView: monthLabel)
            day.autoMatchDimension(.Width, toDimension: .Width, ofView: calendarContainer, withMultiplier: 1/7)
            let dayHeightConstraint = day.autoMatchDimension(.Height, toDimension: .Height, ofView: calendarContainer, withMultiplier: 1/9)
            self.dayOfWeekHeightConstraints.append(dayHeightConstraint)
            if first{
                day.autoPinEdge(.Left, toEdge: .Left, ofView: calendarContainer)
                first = false
            }else{
                day.autoPinEdge(.Left, toEdge: .Right, ofView: prevDayOfWeek!)
            }
            prevDayOfWeek = day
        }
        
        
        first = true
        var currentDayOfWeek = 0
        var prevDate:CalendarViewDateButton?
        for _ in 0...41{
            let dayButton = CalendarViewDateButton()
            dateContainers.append(dayButton)
            calendarContainer.addSubview(dayButton)
            let dayHeightConstraint = dayButton.autoMatchDimension(.Height, toDimension: .Height, ofView: calendarContainer, withMultiplier: 1/7)
            self.dayHeightConstraints.append(dayHeightConstraint)
            dayButton.autoMatchDimension(.Width, toDimension: .Width, ofView: calendarContainer, withMultiplier: 1/7)
            
            if first{
                dayButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: dayLabels[0])
                dayButton.autoPinEdge(.Left, toEdge: .Left, ofView: dayLabels[0])
                first = false
            }else if currentDayOfWeek > 0{
                dayButton.autoPinEdge(.Top, toEdge: .Top, ofView: prevDate!)
                dayButton.autoPinEdge(.Left, toEdge: .Right, ofView: prevDate!)
            }else if currentDayOfWeek == 0{
                dayButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: prevDate!)
                dayButton.autoPinEdge(.Left, toEdge: .Left, ofView: dayLabels[0])
            }
            
            if currentDayOfWeek == 6{
                currentDayOfWeek = 0
            }else{
                currentDayOfWeek += 1
            }
            prevDate = dayButton
        }
        
        //SIDE BUTTONS
        let rightSide = UIView()
        self.addSubview(rightSide)
        rightSide.autoPinEdge(.Left, toEdge: .Right, ofView: allInfoContainer)
        rightSide.autoPinEdge(.Right, toEdge: .Right, ofView: self)
        rightSide.autoPinEdge(.Top, toEdge: .Top, ofView: self)
        rightSide.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
        rightSide.userInteractionEnabled = true
        rightSide.addSubview(forwardMonth)
        self.forwardMonth.autoMatchDimension(.Width, toDimension: .Width, ofView: rightSide, withMultiplier: 1)
        self.forwardMonth.autoMatchDimension(.Height, toDimension: .Height, ofView: rightSide, withMultiplier: 1)
        self.forwardMonth.autoCenterInSuperview()
        let forwardImage = UIImage(named: "ForwardButton.png")
        let forwardButtonImageView = UIImageView(image: forwardImage)
        self.forwardMonth.addSubview(forwardButtonImageView)
        forwardButtonImageView.autoCenterInSuperview()
        forwardButtonImageView.alpha = 0.25
        self.forwardMonth.userInteractionEnabled = true
        self.forwardMonth.addTarget(self, action: #selector(CalendarView.goForwardOneMonth(_:)), forControlEvents: .TouchUpInside)
        
        let leftSide = UIView()
        self.addSubview(leftSide)
        leftSide.autoPinEdge(.Right, toEdge: .Left, ofView: allInfoContainer)
        leftSide.autoPinEdge(.Left, toEdge: .Left, ofView: self)
        leftSide.autoPinEdge(.Top, toEdge: .Top, ofView: self)
        leftSide.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self)
        leftSide.userInteractionEnabled = true
        leftSide.addSubview(backwardMonth)
        self.backwardMonth.autoMatchDimension(.Width, toDimension: .Width, ofView: leftSide, withMultiplier: 1)
        self.backwardMonth.autoMatchDimension(.Height, toDimension: .Height, ofView: leftSide, withMultiplier: 1)
        self.backwardMonth.autoCenterInSuperview()
        let backImage = UIImage(named: "BackButton.png")
        let backButtonImageView = UIImageView(image: backImage)
        self.backwardMonth.addSubview(backButtonImageView)
        backButtonImageView.autoCenterInSuperview()
        backButtonImageView.alpha = 0.25
        self.backwardMonth.userInteractionEnabled = true
        self.backwardMonth.addTarget(self, action: #selector(CalendarView.goBackwardOneMonth(_:)), forControlEvents: .TouchUpInside)
        
        if let width = forwardImage?.size.width{
            if let height = forwardImage?.size.height{
                let ratio = width/height
                forwardButtonImageView.autoSetDimension(.Height, toSize: 30)
                forwardButtonImageView.autoMatchDimension(.Width, toDimension: .Height, ofView: forwardButtonImageView, withMultiplier: ratio)
                backButtonImageView.autoSetDimension(.Height, toSize: 30)
                backButtonImageView.autoMatchDimension(.Width, toDimension: .Height, ofView: backButtonImageView, withMultiplier: ratio)
            }
        }
        //END SIDE BUTTONS
        
        updateCurrentInfo()
        self.modifiedDay = self.currentDay
        self.modifiedMonth = self.currentMonth
        self.modifiedYear = self.currentYear
        self.setMonth(self.currentMonth)
        self.setYear(self.currentYear)
        self.updateMonth(self.currentMonth, year: self.currentYear)
        
        self.addActionToDateButtons(self, action: #selector(CalendarView.updateModifiedDateFromButtonDate(_:)))
    }
    
    func updateHourPosition(){
        
    }
    
    @objc func updateDateInfo(){
        //minutes
        if(self.currentMinute < 60){
            self.currentMinute += 1
        }else{
            self.currentMinute = 0
            
            //hours
            if(self.currentHour < 24){
                self.currentHour += 1
            }else{
                self.currentHour = 0
                
                //days
                if(self.currentDay < self.calendarManager.getNumDaysInMonth(self.currentMonth, year: self.currentYear)){
                    self.currentDay += 1
                }else{
                    self.currentDay = 1
                    
                    //months
                    if(self.currentMonth < 12){
                        self.currentMonth += 1
                    }else{
                        self.currentMonth = 1
                        
                        //years
                        self.currentYear += 1
                    }
                }
            }
        }
    }
    
    
    func updateMonth(month:Int, year:Int){

            self.updateCurrentInfo()
            let prevMonthAndYear = self.getPrevMonthAndYearNumber(month, year: year)
            let numDaysInPrevMonth = self.getNumDaysInMonth(prevMonthAndYear.0, year: prevMonthAndYear.1)
            let nextMonthAndYear = self.getNextMonthAndYearNumber(month, year: year)
            let numDaysInCurrentMonth = self.getNumDaysInMonth(month, year: year)
            let startDay = self.getStartDayInMonth(month, year: year)
        
                //FOR PREVIOUS MONTH'S DAYS
                if(startDay != 0){
                    var day = startDay - 1
                    var difference = 0
                    while(day >= 0){
                        self.dateContainers[day].setDate(prevMonthAndYear.0, day: numDaysInPrevMonth - difference, year: prevMonthAndYear.1)
                        if(self.dateContainers[day].getDate() == self.getCurrentDate()){
                            self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.CurrentDay)
                            self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.PrevMonth)
                        }else{
                            self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.DeselectCurrentDay)
                            self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.PrevMonth)
                        }
                        day -= 1
                        difference += 1
                    }
                }
                
                //FOR CURRENT MONTH'S DAYS
                var date = 1
                for day in startDay...numDaysInCurrentMonth + startDay - 1{
                    self.dateContainers[day].setDate(month, day: date, year: year)
                    if(self.dateContainers[day].getDate() == self.getCurrentDate()){
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.CurrentDay)
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.CurrentlyDisplayedItem)
                    }else{
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.DeselectCurrentDay)
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.Normal)
                    }
                    date += 1
                }
                
                
                //FOR NEXT MONTH'S DAYS
                date = 1
                for day in numDaysInCurrentMonth + startDay...self.dateContainers.count - 1{
                    self.dateContainers[day].setDate(nextMonthAndYear.0, day: date, year: nextMonthAndYear.1)
                    if(self.dateContainers[day].getDate() == self.getCurrentDate()){
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.CurrentDay)
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.NextMonth)
                    }else{
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.DeselectCurrentDay)
                        self.dateContainers[day].setViewStatus(CalendarViewDateButton.SelectionStatus.NextMonth)
                    }
                    date += 1
                }
    }
    
    
    //returns the next valid month and year
    func getNextMonthAndYearNumber(month:Int,year:Int) -> (Int,Int){
        if(month <= 0 || month > 12){
            return (-1,-1) //error
        }
        if(month == 12){
            return (1,year + 1)
        }else{
            return (month + 1, year)
        }
    }
    
    //returns the previous valid month and year
    func getPrevMonthAndYearNumber(month:Int,year:Int) -> (Int,Int){
        if(month <= 0 || month > 12){
            return (-1,-1) //error
        }
        if(month == 1){
            return (12, year - 1)
        }else{
            return (month - 1, year)
        }
    }
    
    func setMonth(monthNumber:Int){
        switch monthNumber{
        case 1:
            self.monthLabel.text = "JANUARY"
            break
        case 2:
            self.monthLabel.text = "FEBRUARY"
            break
        case 3:
            self.monthLabel.text = "MARCH"
            break
        case 4:
            self.monthLabel.text = "APRIL"
            break
        case 5:
            self.monthLabel.text = "MAY"
            break
        case 6:
            self.monthLabel.text = "JUNE"
            break
        case 7:
            self.monthLabel.text = "JULY"
            break
        case 8:
            self.monthLabel.text = "AUGUST"
            break
        case 9:
            self.monthLabel.text = "SEPTEMBER"
            break
        case 10:
            self.monthLabel.text = "OCTOBER"
            break
        case 11:
            self.monthLabel.text = "NOVEMBER"
            break
        case 12:
            self.monthLabel.text = "DECEMBER"
            break
        default:
            self.monthLabel.text = "err"
            break
        }
    }
    
    func setYear(year: Int){
        self.yearLabel.text = "\(year)"
    }
    
    
    func getNumDaysInMonth(month:Int, year:Int) -> Int{
        if(month < 1 || month > 12){
            return 0
        }
        
        let dateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.dateFromComponents(dateComponents)!
        
        let range = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        let numDays = range.length
        return numDays
    }
    
    func getStartDayInMonth(month:Int, year:Int) -> Int{
        let dateComponents = NSDateComponents()
        dateComponents.year = year
        dateComponents.month = month
        
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.dateFromComponents(dateComponents)!
        
        let components:NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: date)
        components.setValue(1, forComponent: .Day)
        let firstDayOfMonthDate = calendar.dateFromComponents(components)
        
        let myComponents = calendar.components(.Weekday, fromDate: firstDayOfMonthDate!)
        let weekDay = myComponents.weekday
        
        return weekDay - 1 //to make zero based
    }
    
    //gets current day, month, and year and updates the corresponding variables
    func updateCurrentInfo(){
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        self.currentDay = (calendar?.component(NSCalendarUnit.Day, fromDate: NSDate()))!
        self.currentMonth = (calendar?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
        self.currentYear = (calendar?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
    }
    
    
    func getCurrentDate() -> String{
        return "\(self.currentMonth)-\(self.currentDay)-\(self.currentYear)"
    }
    
    func getFormattedCurrentDate() -> String{
        return "\(self.monthLabel.text!) \(self.currentDay), \(self.currentYear)"
    }
    
    func getFormattedModifiedDate() -> String{
        return "\(self.monthLabel.text!) \(self.modifiedDay), \(self.modifiedYear)"
    }
    
    func getModifiedDate() -> String{
        return "\(self.modifiedMonth)-\(self.modifiedDay)-\(self.modifiedYear)"
    }
    
    func getModifiedDateStartOfMonth() -> String{
        return "\(self.modifiedMonth)-1-\(self.modifiedYear)"
    }
    
    func goToDate(month: Int, day: Int, year: Int){
        self.modifiedMonth = month
        self.modifiedDay = day
        self.modifiedYear = year
        
        self.updateMonth(month, year: year)
        self.setMonth(self.modifiedMonth)
        self.setYear(self.modifiedYear)
        self.setNeedsLayout()
    }
    
    func incrementOneMonth(){
        if(self.modifiedMonth < 12){
            self.modifiedMonth += 1
        }else{
            self.modifiedMonth = 1
            self.modifiedYear += 1
        }
    }
    
    func decrementOneMonth(){
        if(self.modifiedMonth > 1){
            self.modifiedMonth -= 1
        }else{
            self.modifiedMonth = 12
            self.modifiedYear -= 1
        }
    }
    
    func updateModifiedDate(month:Int,day:Int,year:Int){
        self.modifiedMonth = month
        self.modifiedDay = day
        self.modifiedYear = year
    }
    
//    func disableConstraints(){
//        self.monthLabelHeightConstraint?.active = false
//        self.yearLabelHeightConstraint?.active = false
//        for constraint in self.dayOfWeekHeightConstraints{
//            constraint.active = false
//        }
//        for constraint in self.dayHeightConstraints{
//            constraint.active = false
//        }
//    }
//    
//    func enableConstraints(){
//        self.monthLabelHeightConstraint?.active = true
//        self.yearLabelHeightConstraint?.active = true
//        for constraint in self.dayOfWeekHeightConstraints{
//            constraint.active = true
//        }
//        for constraint in self.dayHeightConstraints{
//            constraint.active = true
//        }
//    }
    
    func goForwardOneMonth(sender:UIButton!){
        self.incrementOneMonth()    //increment the modified month
        self.goToDate(self.modifiedMonth, day: self.modifiedDay, year: self.modifiedYear)   //update the calendar view
    }
    
    func goBackwardOneMonth(sender:UIButton!){
        self.decrementOneMonth()
        self.goToDate(self.modifiedMonth, day: self.modifiedDay, year: self.modifiedYear)
    }
    
    func updateModifiedDateFromButtonDate(sender:UIButton!){
        if let dateButton = sender as? CalendarViewDateButton{
            self.updateModifiedDate(dateButton.month, day: dateButton.day, year: dateButton.year)
        }
    }
    
    func addActionToDateButtons(target: AnyObject, action:Selector){
        for button in self.dateContainers{
            button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        }
    }
    
}