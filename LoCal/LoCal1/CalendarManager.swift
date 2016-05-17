//
//  CalendarManager.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/18/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation
import EventKit

class CalendarManager {
    
    let eventStore = EKEventStore()
    let calendar = NSCalendar.currentCalendar()
    var authorized = false
    var numberOfDaysLoaded = Int()
    
    var currentDay = Int()
    var currentMonth = Int()
    var currentYear = Int()
    
    var currentHour = Int()
    var currentMinute = Int()
    
    var timer:NSTimer? = nil
    
    init(){
        let calendar = NSCalendar.init(calendarIdentifier: NSCalendarIdentifierGregorian)
        self.currentDay = (calendar?.component(NSCalendarUnit.Day, fromDate: NSDate()))!
        self.currentMonth = (calendar?.component(NSCalendarUnit.Month, fromDate: NSDate()))!
        self.currentYear = (calendar?.component(NSCalendarUnit.Year, fromDate: NSDate()))!
        numberOfDaysLoaded = getNumDaysInYear(self.currentYear) + getNumDaysInYear(self.currentYear - 1)
        checkStatus()
        
        let date = NSDate()
        let components = calendar!.components([.NSHourCalendarUnit , .NSMinuteCalendarUnit , .NSSecondCalendarUnit], fromDate: date)
        
        self.currentHour = components.hour
        self.currentMinute = components.minute
        let second = components.second
        
        let beginTimerAfter = 60 - second
        //Begin the timer on the minute (for accuracy)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Double(beginTimerAfter)*Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.updateDateInfo()
            //update the calendar info every 60 seconds
            self.timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: #selector(CalendarManager.updateDateInfo), userInfo: nil, repeats: true)
        })
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
                if(self.currentDay < self.getNumDaysInMonth(self.currentMonth, year: self.currentYear)){
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
    
    ///Creates a map of all the dates and their corresponding row numbers (for use with a UITableView)
    func fillDateMap() -> [String:Int]{
        var dateMap = [String:Int]()
        var rowIndex = 0
        for myYear in self.currentYear-5...self.currentYear+5{
            for myMonth in 1...12{
                for myDay in 1...self.getNumDaysInMonth(myMonth, year: myYear){
                    dateMap["\(myMonth)-\(myDay)-\(myYear)"] = rowIndex
                    rowIndex += 1
                }
            }
        }
        numberOfDaysLoaded = dateMap.count
        return dateMap
    }
    
    ///Check to see if the user has given access to the phone's calendar
    func checkStatus(){
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            eventStore.requestAccessToEntityType(.Event, completion: {_,_ in
                print("has access")
                if EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) == EKAuthorizationStatus.Authorized{
                    self.authorized = true
                }
            })
            break
        case EKAuthorizationStatus.Authorized:
            print("Authorized")
            self.authorized = true
            break
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            print("Denied")
            eventStore.requestAccessToEntityType(.Event, completion: {_,_ in print("")})
            break
        }
    }
    
    ///Make an NSDate object given a month, day and year
    func makeNSDateFromComponents(month:Int, day:Int, year:Int) -> NSDate{
        let newDateComponents = NSDateComponents()
        newDateComponents.day = day
        newDateComponents.month = month
        newDateComponents.year = year
        let newDate = NSCalendar.currentCalendar().dateFromComponents(newDateComponents)
        return newDate!
    }
    
    ///Get a list of all the events that happen on a given date
    func getEventsForDate(date: NSDate) -> [EKEvent]{
        let beginningOfDay = calendar.startOfDayForDate(date)
        
        var endOfDay: NSDate? {
            let components = NSDateComponents()
            components.day = 1
            components.second = -1
            return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: beginningOfDay, options: NSCalendarOptions())
        }
        
        let calendars = eventStore.calendarsForEntityType(.Event)
        var myEvents = [EKEvent]()
        
        for calendar in calendars {
            //if calendar.title == "Work" {
            
            let myPredicate = eventStore.predicateForEventsWithStartDate(beginningOfDay, endDate: endOfDay!, calendars: [calendar])
            let events = eventStore.eventsMatchingPredicate(myPredicate)
                for event in events {
                    //print(event.title)
                    //print(getFormattedEventStartTime(event))
//                    titles.append(event.title)
//                    startDates.append(event.startDate)
//                    endDates.append(event.endDate)
                    myEvents.append(event)
                }
            //}
        }
        return myEvents
    }
    
    ///Get the time an event starts in decimal form (i.e. 1:30 would be 13.5)
    func getEventStartTimeForUI(event: EKEvent) -> Double{
        let timestamp = NSDateFormatter.localizedStringFromDate(event.startDate, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let timeComponents = timestamp.componentsSeparatedByString(" ")
        let time = timeComponents[0].componentsSeparatedByString(":")
        
        var timeNumber:Double = 0
        
        //get the initial hour
        timeNumber = Double(time[0])!
        if(timeComponents[1] == "PM" && timeNumber < 12){
            timeNumber += 12
        }else if(timeComponents[1] == "AM" && time[0] == "12"){
            timeNumber = 0
        }
        //get the fraction of the hour
        timeNumber += (Double(time[1])!/60)
        
        return timeNumber
    }
    
    ///Get the time an event ends in decimal form (i.e. 1:30 would be 13.5)
    func getEventEndTimeForUI(event: EKEvent) -> Double{
        let timestamp = NSDateFormatter.localizedStringFromDate(event.endDate, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let timeComponents = timestamp.componentsSeparatedByString(" ")
        let time = timeComponents[0].componentsSeparatedByString(":")
        
        var timeNumber:Double = 0
        
        //get the initial hour
        timeNumber = Double(time[0])!
        if(timeComponents[1] == "PM" && timeNumber < 12){
            timeNumber += 12
        }
        //get the fraction of the hour
        timeNumber += (Double(time[1])!/60)
        
        return timeNumber
    }
    
    ///Get the start time in string format (hh:mm pm/am)
    func getFormattedEventStartTime(event: EKEvent) -> String{
        let timestamp = NSDateFormatter.localizedStringFromDate(event.startDate, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let timePieces = timestamp.componentsSeparatedByString(" ")
        
        if(timePieces.count == 2){
            if(timePieces[1] == "AM"){
                return "\(timePieces[0])am"
            }else{
                return "\(timePieces[0])pm"
            }
        }
        return timestamp
    }
    
    ///Get the end time in string format (hh:mm pm/am)
    func getFormattedEventEndTime(event: EKEvent) -> String{
        let timestamp = NSDateFormatter.localizedStringFromDate(event.endDate, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        let timePieces = timestamp.componentsSeparatedByString(" ")
        
        if(timePieces.count == 2){
            if(timePieces[1] == "AM"){
                return "\(timePieces[0])am"
            }else{
                return "\(timePieces[0])pm"
            }
        }
        return timestamp
    }
    
    ///Gets the latitude and longitude of an event's location
    func getEventLocationCoords(event: EKEvent) -> EKStructuredLocation? {
        print(event.structuredLocation)
        return event.structuredLocation
    }
    
    ///Get the string (mm-dd-yyyy) for an NSDate
    func getDateString(date: NSDate) -> String{
        let components = calendar.components([.Day , .Month , .Year], fromDate: date)
        let year =  components.year
        let month = components.month
        let day = components.day
        
        return "\(month)-\(day)-\(year)"
    }
    
    ///Get the formatted string (mm-dd-yyyy) for a given month, date, and year
    func getDateString(month:Int,day:Int,year:Int) -> String{
        return "\(month)-\(day)-\(year)"
    }
    
    ///Get the formatted string (mm-dd-yyyy) for the current day
    func getCurrentDateString() -> String{
        return getDateString(self.currentMonth, day: self.currentDay, year: self.currentYear)
    }
    
    ///Get a tuple (month, day, year) based off of the current day plus an offset
    func getDateFromCurrentDateWithOffset(offset:Int) -> (Int,Int,Int){
        let newDateComponents = NSDateComponents()
        newDateComponents.day = self.currentDay + offset
        newDateComponents.month = self.currentMonth
        newDateComponents.year = self.currentYear
        let newDate = NSCalendar.currentCalendar().dateFromComponents(newDateComponents)
        
        if let date = newDate{
            let newComponents = calendar.components([.Day, .Month, .Year], fromDate: date)
            let day = newComponents.day
            let month = newComponents.month
            let year = newComponents.year
            let dateTuple = (month, day, year)
            return dateTuple
        }
        return (-1,-1,-1) //error
    }
    
    ///Get the number of days in a given year
    func getNumDaysInYear(year:Int) -> Int{
        var totalDays = 0
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = NSDateComponents()
        dateComponents.year = year
        
        for month in 1...12{
            dateComponents.month = month
            let date = calendar.dateFromComponents(dateComponents)!
            let range = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
            totalDays += range.length
        }
        return totalDays
    }
    
    //Get the number of days in a given month
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
    
    ///Get the day of the week (integer) based on the string given (mm-dd-yyyy)
    func getDayOfWeek(today:String)->Int {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let todayDate = formatter.dateFromString(today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        return weekDay
    }
    
    //Get a list of color values based on how much of each hour has been taken up by events
    func getColorValuesForHours(events:[EKEvent]) -> [UIColor]{
        //var hourValues:[Double] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        //var hourValues = [UIColor](count: 24, repeatedValue: UIColor(red: 20/255, green: 60/255, blue: 90/255, alpha: 1))
        
        //0 is red
        //1 is green
        //2 is blue
        //var rgbVals = [(CGFloat,CGFloat,CGFloat)](count: 24, repeatedValue: (CGFloat(0/255),CGFloat(50/255),CGFloat(100/255)))
        //var rgbVals = [(CGFloat,CGFloat,CGFloat)](count: 24, repeatedValue: (CGFloat(0/255),CGFloat(50/255),CGFloat(100/255)))
        let h:CGFloat = 208 //92
        let s:CGFloat = 72 //72
        let b:CGFloat = 30 //61.6
        var hsbVals = [(CGFloat,CGFloat,CGFloat)] (count: 24, repeatedValue: (((h/360),(s/100),(b/100))))
        
        
        let changeByVal:CGFloat = 50/100
        
        for event in events{
            if(!event.allDay){
                
                let startTime = self.getEventStartTimeForUI(event)
                let endTime = self.getEventEndTimeForUI(event)
                
                let startHour:Int = Int(startTime)
                let endHour:Int = Int(ceil(endTime))
                
                //update all the hours
                if startHour <= endHour{
                        var hour = startHour
                        
                        while(hour < endHour ){
                            //if the event is less than one hour
                            if(startHour == endHour){
                                //if the event is 0 in length
                                if(startTime == endTime){
//                                    rgbVals[hour].0 += changeByVal
//                                    rgbVals[hour].1 += changeByVal/2
//                                    rgbVals[hour].2 += changeByVal
                                    hsbVals[hour].2 += changeByVal
                                }else{
//                                    rgbVals[hour].0 += changeByVal * (CGFloat(endTime) - CGFloat(startTime))
//                                    rgbVals[hour].1 += (changeByVal * (CGFloat(endTime) - CGFloat(startTime)))/2
//                                    rgbVals[hour].2 += changeByVal * (CGFloat(endTime) - CGFloat(startTime))
                                    hsbVals[hour].2 += changeByVal * (CGFloat(endTime) - CGFloat(startTime))
                                }
                            }else if(hour == startHour){
                                if(startTime == Double(startHour)){
//                                    rgbVals[hour].0 += changeByVal
//                                    rgbVals[hour].1 += changeByVal/2
//                                    rgbVals[hour].2 += changeByVal
                                    hsbVals[hour].2 += changeByVal
                                }else{
//                                    rgbVals[hour].0 += changeByVal * (CGFloat(startTime) - CGFloat(startHour))
//                                    rgbVals[hour].1 += (changeByVal * (CGFloat(startTime) - CGFloat(startHour)))/2
//                                    rgbVals[hour].2 += changeByVal * (CGFloat(startTime) - CGFloat(startHour))
                                    hsbVals[hour].2 += changeByVal * (1 - (CGFloat(startTime) - CGFloat(startHour)))
                                }
                            }else if(hour == endHour - 1){
                                if(endTime == Double(endHour)){
//                                    rgbVals[hour].0 += changeByVal
//                                    rgbVals[hour].1 += changeByVal/2
//                                    rgbVals[hour].2 += changeByVal
                                    hsbVals[hour].2 += changeByVal
                                }else{
//                                    rgbVals[hour].0 += changeByVal * (1 - (CGFloat(endHour) - CGFloat(endTime)))
//                                    rgbVals[hour].1 += (changeByVal * (1 - (CGFloat(endHour) - CGFloat(endTime))))/2
//                                    rgbVals[hour].2 += changeByVal * (1 - (CGFloat(endHour) - CGFloat(endTime)))
                                    hsbVals[hour].2 += changeByVal * (1 - (CGFloat(endHour) - CGFloat(endTime)))
                                }
                            }else{
//                                rgbVals[hour].0 += changeByVal
//                                rgbVals[hour].1 += changeByVal/2
//                                rgbVals[hour].2 += changeByVal
                                hsbVals[hour].2 += changeByVal
                            }
                            hour += 1
                        }                    
                }
            }
        }
        
        var hourValues = [UIColor]()
//        for rgb in rgbVals{
//            hourValues.append(UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1))
//        }
        for hsb in hsbVals{
            hourValues.append(UIColor(hue: hsb.0, saturation: hsb.1, brightness: hsb.2, alpha: 1))
        }
        return hourValues
    }
    
    ///Returns the three letter day in caps given the day of the week (1 being Sunday)
    func getDayString(dayNumber: Int) -> String{
        switch dayNumber{
        case 1:
            return "SUN"
        case 2:
            return "MON"
        case 3:
            return "TUE"
        case 4:
            return "WED"
        case 5:
            return "THU"
        case 6:
            return "FRI"
        case 7:
            return "SAT"
        default:
            return "err"
        }
    }
}