//
//  CalendarViewDateButton.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/14/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class CalendarViewDateButton: UIButton {
    
    let normalColor = ColorManager.normalColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    var day = Int()
    var month = Int()
    var year = Int()
    
    var labelView = UIView()
    var dayLabel = UILabel()
    
    enum SelectionStatus{
        case Normal
        case SelectedItem
        case CurrentlyDisplayedItem
        case Deselected
        case CurrentDay
        case DeselectCurrentDay
        case NextMonth
        case PrevMonth
        case None
    }
    
    var status = SelectionStatus.None
    
    
    convenience init (month:Int, day: Int, year:Int) {
        self.init(frame:CGRect.zero)
        self.initialize()
    
        dayLabel.text = "\(day)"

        self.day = day
        self.month = month
        self.year = year
    }
    
    convenience init (){
        self.init(frame:CGRect.zero)
        self.initialize()
    }
    
    func initialize(){
        self.addSubview(labelView)
        self.labelView.autoMatchDimension(.Height, toDimension: .Height, ofView: self, withMultiplier: 0.85)
        self.labelView.autoMatchDimension(.Width, toDimension: .Width, ofView: self, withMultiplier: 0.85)
        self.labelView.autoCenterInSuperview()
        self.labelView.layer.cornerRadius = 10
        
        self.labelView.addSubview(dayLabel)
        dayLabel.textAlignment = .Center
        dayLabel.autoCenterInSuperview()
        
        self.userInteractionEnabled = true
        self.labelView.userInteractionEnabled = false
        
        dayLabel.textColor = whiteColor
        self.setViewStatus(.Normal)
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setDate(month:Int,day:Int,year:Int){
        self.month = month
        self.day = day
        self.year = year
        self.dayLabel.text = "\(day)"
    }
    
    func setViewStatus(status: SelectionStatus){
        
        //let animationTime = 0.0
        var debugging = false
        
        switch status {
        case .Normal:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set normal")
//                //END DEBUGGING CODE
//            }
            
            self.labelView.layer.borderColor = UIColor.clearColor().CGColor
            self.labelView.layer.borderWidth = 0
            self.labelView.alpha = 0.7
            if self.status != SelectionStatus.CurrentDay{
                self.status = .Normal
                self.labelView.backgroundColor = self.normalColor
            }
            break
        case .CurrentlyDisplayedItem:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set currentlyDisplayed")
//                //END DEBUGGING CODE
//            }
            
            self.labelView.layer.borderColor = self.blueColor.CGColor
            self.labelView.layer.borderWidth = 2
            self.labelView.alpha = 1
            if self.status != SelectionStatus.CurrentDay && self.status != .PrevMonth && self.status != .NextMonth{
                self.status = .CurrentlyDisplayedItem
            }
            break
        case .CurrentDay:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set currentDay")
//                //END DEBUGGING CODE
//            }
            
            self.labelView.backgroundColor = self.blueColor
            if self.status != SelectionStatus.CurrentDay{
                self.status = .CurrentDay
            }
            break
        case .SelectedItem:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set selected item")
//                //END DEBUGGING CODE
//            }
            
                self.labelView.layer.borderColor = self.greenColor.CGColor
                self.labelView.layer.borderWidth = 2
                if self.status != SelectionStatus.CurrentDay{
                    self.status = .SelectedItem
                }
            break
        case .Deselected:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set deselected")
//                //END DEBUGGING CODE
//            }
            
                self.labelView.layer.borderColor = UIColor.clearColor().CGColor
                self.labelView.layer.borderWidth = 0
                if self.status != SelectionStatus.CurrentDay{
                    self.status = .Deselected
                }
            break
        case .NextMonth:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set next month")
//                //END DEBUGGING CODE
//            }
            
            self.labelView.alpha = 0.2
            self.status = .NextMonth
            break
        case .PrevMonth:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set previous month")
//                //END DEBUGGING CODE
//            }
            
            self.labelView.alpha = 0.2
            self.status = .PrevMonth
            break
        case .DeselectCurrentDay:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set DeselectCurrentDay")
//                //END DEBUGGING CODE
//            }
            
            self.status = .Normal
            self.setViewStatus(.Normal)
        default:
            
//            if debugging{
//                //DEBUGGING CODE
//                print("--")
//                print(self.getDate())
//                print("[+] set default")
//                //END DEBUGGING CODE
//            }
            
            if self.status != SelectionStatus.CurrentDay{
                self.status = .None
            }
            break
        }
    }
    
    func getDate()->String{
        return "\(self.month)-\(self.day)-\(self.year)"
    }
}