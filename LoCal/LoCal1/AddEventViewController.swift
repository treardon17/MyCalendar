//
//  AddEventViewController.swift
//  LoCalendar
//
//  Created by Drew Roberts on 5/6/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation
import UIKit

class AddEventViewController: UIViewController {
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    let exitButtonIMG = UIImage(named: "AddEventButtonPlus.png")
    let eventName = UITextField()
    let changeStartDateButton = UIButton()
    let changeEndDateButton = UIButton()
    let startDateCalendarContainer = UIView()
    let endDateCalendarContainer = UIView()
    let startDateCalendar = CalendarView()
    let endDateCalendar = CalendarView()
    let startDateHeatMap = DayHeatMap()
    let endDateHeatMap = DayHeatMap()
    
    var startDateCalendarIsOpen = false
    var endDateCalendarIsOpen = false
    var startDateString = String()
    var endDateString = String()
    var startDateCalendarHeightConstraint:NSLayoutConstraint?
    var endDateCalendarHeightConstraint:NSLayoutConstraint?
    var bottomOfStartDateCalendarView:NSLayoutConstraint?
    var bottomOfEndDateCalendarView:NSLayoutConstraint?
    
    override func viewDidLoad() {
        let addLocationFromSaved = NavButton(buttonColor: greenColor, imageFileName: "AddLocation.png")
        let searchMapButton = NavButton(buttonColor: blueColor, imageFileName: "SearchMapButton.png")
        self.view.backgroundColor = darkColor
        let font = UIFont.systemFontOfSize(40)
        let font2 = UIFont.systemFontOfSize(20)
        
        let exitButton = UIImageView(image: exitButtonIMG)
        self.view.addSubview(exitButton)
        exitButton.autoPinEdge(.Top, toEdge: .Top, ofView: self.view, withOffset: 5)
        exitButton.autoPinEdge(.Left, toEdge: .Left, ofView: self.view, withOffset: 5)
        exitButton.transform = CGAffineTransformMakeRotation((CGFloat(M_PI)/180)*45)
        exitButton.userInteractionEnabled = true
        let exitTap = UITapGestureRecognizer(target: self, action: #selector(AddEventViewController.exit(_:)))
        exitButton.addGestureRecognizer(exitTap)
        
        self.view.addSubview(eventName)
        eventName.text = "Event Name"
        eventName.font = font
        eventName.autoSetDimension(.Height, toSize: 50)
        eventName.borderStyle = UITextBorderStyle.RoundedRect
        eventName.autoPinEdge(.Left, toEdge: .Left, ofView: self.view, withOffset: 20)
        eventName.autoPinEdge(.Right, toEdge: .Right, ofView: self.view, withOffset: -20)
        eventName.autoPinEdge(.Top, toEdge: .Bottom, ofView: exitButton, withOffset: 50)
        eventName.backgroundColor = lightDarkColor
        eventName.textColor = whiteColor

        //START DATE
        self.view.addSubview(changeStartDateButton)
        changeStartDateButton.autoPinEdge(.Right, toEdge: .Right, ofView: eventName)
        changeStartDateButton.autoPinEdge(.Left, toEdge: .Left, ofView: eventName)
        changeStartDateButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: eventName, withOffset: 20)
        changeStartDateButton.backgroundColor = lightDarkColor
        changeStartDateButton.setTitle("TAP TO SET START DATE", forState: UIControlState.Normal)
        changeStartDateButton.setTitleColor(greenColor, forState: UIControlState.Normal)
        changeStartDateButton.addTarget(self, action: #selector(AddEventViewController.toggleStartDateCalendar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(startDateCalendarContainer)
        startDateCalendarContainer.backgroundColor = greenColor
        startDateCalendarContainer.autoPinEdge(.Left, toEdge: .Left, ofView: self.view)
        startDateCalendarContainer.autoPinEdge(.Right, toEdge: .Right, ofView: self.view)
        startDateCalendarContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: changeStartDateButton)
        startDateCalendarHeightConstraint = startDateCalendarContainer.autoMatchDimension(.Height, toDimension: .Height, ofView: self.view, withMultiplier: CGFloat(CalendarView.calendarContainerHeightMultiplyer))
        startDateCalendarHeightConstraint?.active = false
        self.bottomOfStartDateCalendarView = startDateCalendarContainer.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: changeStartDateButton)
        
        startDateCalendarContainer.addSubview(startDateCalendar)
        startDateCalendar.autoPinEdge(.Left, toEdge: .Left, ofView: startDateCalendarContainer)
        startDateCalendar.autoPinEdge(.Right, toEdge: .Right, ofView: startDateCalendarContainer)
        startDateCalendar.autoPinEdge(.Top, toEdge: .Top, ofView: startDateCalendarContainer)
        startDateCalendar.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: startDateCalendarContainer)
        startDateCalendar.monthLabel.textColor = darkColor
        startDateCalendar.hidden = true
        startDateCalendar.addActionToDateButtons(self, action: #selector(AddEventViewController.selectStartDate(_:)))
        //END START DATE
        
        self.view.addSubview(startDateHeatMap)
        startDateHeatMap.autoPinEdge(.Top, toEdge: .Bottom, ofView: startDateCalendarContainer, withOffset: 20)
        startDateHeatMap.autoSetDimension(.Height, toSize: 30)
        startDateHeatMap.autoSetDimension(.Width, toSize: 100)
        startDateHeatMap.autoPinEdge(.Left, toEdge: .Left, ofView: eventName)

        //END DATE
        self.view.addSubview(changeEndDateButton)
        changeEndDateButton.autoPinEdge(.Left, toEdge: .Left, ofView: eventName)
        changeEndDateButton.autoPinEdge(.Right, toEdge: .Right, ofView: eventName)
        changeEndDateButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: startDateHeatMap, withOffset: 20)
        changeEndDateButton.backgroundColor = lightDarkColor
        changeEndDateButton.setTitle("TAP TO SET END DATE", forState: UIControlState.Normal)
        changeEndDateButton.setTitleColor(greenColor, forState: UIControlState.Normal)
        changeEndDateButton.addTarget(self, action: #selector(AddEventViewController.toggleEndDateCalendar(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(endDateCalendarContainer)
        endDateCalendarContainer.backgroundColor = blueColor
        endDateCalendarContainer.autoPinEdge(.Left, toEdge: .Left, ofView: self.view)
        endDateCalendarContainer.autoPinEdge(.Right, toEdge: .Right, ofView: self.view)
        endDateCalendarContainer.autoPinEdge(.Top, toEdge: .Bottom, ofView: changeEndDateButton)
        endDateCalendarHeightConstraint = endDateCalendarContainer.autoMatchDimension(.Height, toDimension: .Height, ofView: self.view, withMultiplier: CGFloat(CalendarView.calendarContainerHeightMultiplyer))
        endDateCalendarHeightConstraint?.active = false
        self.bottomOfEndDateCalendarView = endDateCalendarContainer.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: changeEndDateButton)
        
        self.view.addSubview(endDateHeatMap)
        endDateHeatMap.autoPinEdge(.Top, toEdge: .Bottom, ofView: endDateCalendarContainer, withOffset: 20)
        endDateHeatMap.autoPinEdge(.Left, toEdge: .Left, ofView: eventName)
        
        endDateCalendarContainer.addSubview(endDateCalendar)
        endDateCalendar.autoPinEdge(.Left, toEdge: .Left, ofView: endDateCalendarContainer)
        endDateCalendar.autoPinEdge(.Right, toEdge: .Right, ofView: endDateCalendarContainer)
        endDateCalendar.autoPinEdge(.Top, toEdge: .Top, ofView: endDateCalendarContainer)
        endDateCalendar.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: endDateCalendarContainer)
        endDateCalendar.monthLabel.textColor = darkColor
        endDateCalendar.hidden = true
        endDateCalendar.addActionToDateButtons(self, action: #selector(AddEventViewController.selectEndDate(_:)))
        //END END DATE
        
        self.view.addSubview(addLocationFromSaved)
        addLocationFromSaved.autoPinEdge(.Top, toEdge: .Bottom, ofView: endDateCalendarContainer, withOffset: 20)
        addLocationFromSaved.autoPinEdge(.Right, toEdge: .Right, ofView: eventName)
        
        self.view.addSubview(searchMapButton)
        searchMapButton.autoPinEdge(.Top, toEdge: .Bottom, ofView: endDateCalendarContainer, withOffset: 20)
        searchMapButton.autoPinEdge(.Right, toEdge: .Left, ofView: addLocationFromSaved, withOffset: -20)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func exit(e: UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func toggleStartDateCalendar(sender: UIButton!){
        if(!startDateCalendarIsOpen){
            showStartDateCalendar()
        }
        else{
            hideStartDateCalendar()
        }
    }
    
    func toggleEndDateCalendar(sender: UIButton!){
        if(!endDateCalendarIsOpen){
            showEndDateCalendar()
        }
        else{
            hideEndDateCalendar()
        }
    }
    
    func hideStartDateCalendar(){
        changeStartDateButton.setTitle(startDateCalendar.getFormattedModifiedDate(), forState: UIControlState.Normal)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.startDateCalendarHeightConstraint?.active = false
            self.bottomOfStartDateCalendarView!.active = true
            self.startDateCalendar.hidden = true
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.startDateCalendarIsOpen = false
                
        })
    }
    
    func showStartDateCalendar(){
        changeStartDateButton.setTitle(startDateCalendar.getFormattedModifiedDate(), forState: UIControlState.Normal)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.bottomOfStartDateCalendarView!.active = false
            self.startDateCalendarHeightConstraint?.active = true
            self.startDateCalendar.hidden = false
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.startDateCalendarIsOpen = true
        })
    }
    
    func hideEndDateCalendar(){
        changeEndDateButton.setTitle(endDateCalendar.getFormattedModifiedDate(), forState: UIControlState.Normal)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.endDateCalendarHeightConstraint?.active = false
            self.bottomOfEndDateCalendarView!.active = true
            self.endDateCalendar.hidden = true
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.endDateCalendarIsOpen = false
        })
    }
    
    func showEndDateCalendar(){
        changeEndDateButton.setTitle(endDateCalendar.getFormattedModifiedDate(), forState: UIControlState.Normal)
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
            self.bottomOfEndDateCalendarView!.active = false
            self.endDateCalendar.hidden = false
            self.endDateCalendarHeightConstraint?.active = true
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.endDateCalendarIsOpen = true
        })
    }
    
    func selectStartDate(sender:UIButton!){
        print("start date selected")
        if let date = sender as? CalendarViewDateButton{
            print(date.getDate())
        }
        hideStartDateCalendar()
    }
    
    func selectEndDate(sender:UIButton!){
        print("end date selected")
        if let date = sender as? CalendarViewDateButton{
            print(date.getDate())
        }
        hideEndDateCalendar()
    }
    
}


