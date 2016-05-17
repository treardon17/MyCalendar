//
//  DayTable.swift
//  LoCalendar
//
//  Created by Tyler Reardon on 4/22/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation

class DayTable: UITableView {
    
    enum ScrollDirections{
        case Up
        case Down
        case None
    }
    
    var dayTableScrollDirection = ScrollDirections.None
    var scrolling = false
    var systemScrolling = false
    
    convenience init(){
        self.init(frame: CGRect.zero, style: .Plain)
    }

    
    func getScrollDirection(scrollVelocity: CGFloat) -> ScrollDirections{
        
        if(scrollVelocity > 0){
            dayTableScrollDirection = .Up
        }else if (scrollVelocity < 0){
            dayTableScrollDirection = .Down
        }else{
            dayTableScrollDirection = .None
        }
        
        return dayTableScrollDirection
    }
    
    func setScrollDirectionNone(){
        self.dayTableScrollDirection = .None
    }
}
