//
//  DayEventsViewController.swift
//  LoCalendar
//
//  Created by Drew Roberts on 4/24/16.
//  Copyright © 2016 Tyler Reardon. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import EventKit
import CoreLocation

class DayEventsViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let cellSelectColor = ColorManager.cellSelectColor
    let darkColor = ColorManager.darkColor
    let whiteColor = ColorManager.whiteColor
    let lightDarkColor = ColorManager.lightDarkColor
    let blueColor = ColorManager.blueColor
    let greenColor = ColorManager.greenColor
    
    let mapContainer = UIView(forAutoLayout: ())
    let myMap = MKMapView(forAutoLayout: ())
    let eventView = UIView()
    var eventViewSliderArrowDown:UIImageView? = nil //(named: "DownArrow.png")
    var eventViewSliderArrow:UIImageView? = nil
    var eventViewSlider = UIView()
    let eventViewSliderSize:CGFloat = 50
    let exitButtonIMG = UIImage(named: "AddEventButtonPlus.png")
    
    var initialLocation:CLLocation? = nil
    let regionRadius = 1000.0

    //variables to allow the animation to fullscreen map
    var mapContainerConstraint = NSLayoutConstraint()
    var halfShowingArrowConstraint = NSLayoutConstraint()
    var bottomOfMapArrowConstraint = NSLayoutConstraint()
    var heightOfMapConstraint = NSLayoutConstraint()
    var bottomMapConstraint = NSLayoutConstraint()
    var fullScreenMap = false
    
    let locationManager = LocationManager()
    let calendarManager = CalendarManager()
    var dayEvents = [EKEvent]()
    var dateBeingViewed:NSDate? = nil
    
    let eventTable = UITableView()
    
    
    convenience init(month:Int, day:Int, year:Int){
        self.init()
        calendarManager.checkStatus()
        initialLocation = locationManager.getGeoLocation()
        dateBeingViewed = calendarManager.makeNSDateFromComponents(month, day: day, year: year)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let downArrow = UIImage(named: "DownArrow.png")
        self.eventViewSliderArrowDown = UIImageView(image: downArrow)
        
        self.view.backgroundColor = darkColor
        self.view.addSubview(mapContainer)
        self.view.addSubview(eventView)
        self.view.bringSubviewToFront(mapContainer)
        eventView.backgroundColor = darkColor
        eventView.autoPinEdgeToSuperviewEdge(.Bottom)
        eventView.autoPinEdgeToSuperviewEdge(.Right)
        eventView.autoPinEdgeToSuperviewEdge(.Left)
        eventView.addSubview(eventTable)
        
        //Event table
        eventTable.autoPinEdgeToSuperviewEdge(.Left)
        eventTable.autoPinEdgeToSuperviewEdge(.Right)
        eventTable.autoPinEdgeToSuperviewEdge(.Bottom)
        eventTable.autoPinEdge(.Top, toEdge: .Top, ofView: eventView, withOffset: eventViewSliderSize/2)
        eventTable.dataSource = self
        eventTable.registerClass(EventCell.self, forCellReuseIdentifier: "EventCell")
        eventTable.backgroundColor = darkColor
        
        mapContainer.autoPinEdge(.Top, toEdge: .Top, ofView: self.view)
        mapContainer.autoPinEdge(.Left, toEdge: .Left, ofView: self.view)
        mapContainer.autoPinEdge(.Right, toEdge: .Right, ofView: self.view)
        
        mapContainerConstraint = mapContainer.autoPinEdge(.Bottom, toEdge: .Top, ofView: eventView)
        heightOfMapConstraint = mapContainer.autoMatchDimension(.Height, toDimension: .Height, ofView: self.view, withMultiplier: 0.30)
        bottomMapConstraint = mapContainer.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: self.view)
        bottomMapConstraint.active = false
        
        //map
        mapContainer.addSubview(myMap)
        myMap.autoPinEdgesToSuperviewEdges()
        myMap.delegate = self
        myMap.showsUserLocation = true
        centerMapOnLocation(initialLocation!)
        self.updateMapViewEvents()
        
        //exit
        let exitButton = UIImageView(image: exitButtonIMG)
        mapContainer.addSubview(exitButton)
        exitButton.autoPinEdge(.Top, toEdge: .Top, ofView: mapContainer, withOffset: 5)
        exitButton.autoPinEdge(.Left, toEdge: .Left, ofView: mapContainer, withOffset: 5)
        exitButton.transform = CGAffineTransformMakeRotation((CGFloat(M_PI)/180)*45)
        exitButton.userInteractionEnabled = true
        let exitTap = UITapGestureRecognizer(target: self, action: #selector(DayEventsViewController.exit(_:)))
        exitButton.addGestureRecognizer(exitTap)
        
        //event view slider
        self.eventViewSliderArrow = eventViewSliderArrowDown
        let sizeRatio = (eventViewSliderArrow!.frame.size.width)/(eventViewSliderArrow!.frame.size.height)
        eventViewSliderArrow!.autoSetDimension(.Height, toSize: 20)
        eventViewSliderArrow!.autoMatchDimension(.Width, toDimension: .Height, ofView: eventViewSliderArrow!, withMultiplier: sizeRatio)
        eventViewSlider.addSubview(eventViewSliderArrow!)
        eventViewSliderArrow!.autoCenterInSuperview()
        eventViewSlider.autoSetDimension(.Width, toSize: eventViewSliderSize)
        eventViewSlider.autoSetDimension(.Height, toSize: eventViewSliderSize)
        eventViewSlider.layer.cornerRadius = eventViewSliderSize/2
        eventViewSlider.backgroundColor = darkColor
        self.view.addSubview(eventViewSlider)
        eventViewSlider.userInteractionEnabled = true
        self.bottomOfMapArrowConstraint = eventViewSlider.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: mapContainer, withOffset: -5)
        self.bottomOfMapArrowConstraint.active = false
        self.halfShowingArrowConstraint = eventViewSlider.autoPinEdge(.Bottom, toEdge: .Bottom, ofView: mapContainer, withOffset: eventViewSliderSize/2)
        eventViewSlider.autoAlignAxisToSuperviewAxis(.Vertical)
        let slide = UIPanGestureRecognizer(target: self, action: #selector(DayEventsViewController.changeDimensions(_:)))
        let arrowTap = UITapGestureRecognizer(target: self, action: #selector(DayEventsViewController.slideOnTap(_:)))
        eventViewSlider.addGestureRecognizer(slide)
        eventViewSlider.addGestureRecognizer(arrowTap)
    }
    
    override func viewDidAppear(animated: Bool) {
        locationManager.updateMapViewToFitAnnotations(myMap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func centerMapOnLocation(location: CLLocation){
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        myMap.setRegion(coordinateRegion, animated: true)
    }
    
    func changeDimensions(s: UIPanGestureRecognizer){
        if(!self.fullScreenMap){
            if(s.state == UIGestureRecognizerState.Ended && s.locationInView(self.view).y >= self.view.frame.height*(1/5) && s.velocityInView(self.view).y > 0){
                print(self.view.frame.height*(1/5))
                print(s.locationInView(self.view).y)
                print("Slide down velocity: ", s.velocityInView(self.view))
                slideDownAnimation()
            }
        }else{
            if(s.state == UIGestureRecognizerState.Ended && s.locationInView(self.view).y <= self.view.frame.height && s.velocityInView(self.view).y < 0){
                print(self.view.frame.height*(1/5))
                print(s.locationInView(self.view).y)
                print("Slide up velocity: ", s.velocityInView(self.view))
                slideUpAnimation()
            }
        }
    }
    
    func slideDownAnimation(){
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.eventViewSlider.transform = CGAffineTransformMakeRotation(180 * CGFloat(M_PI)/180)
                self.halfShowingArrowConstraint.active = false
                self.heightOfMapConstraint.active = false
                self.bottomOfMapArrowConstraint.active = true
                self.bottomMapConstraint.active = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }, completion: { finished in
                self.fullScreenMap = true
                self.locationManager.updateMapViewToFitAnnotations(self.myMap)
        })

    }
    
    func slideUpAnimation(){
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 2, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: {
                self.eventViewSlider.transform = CGAffineTransformIdentity
                self.bottomMapConstraint.active = false
                self.bottomOfMapArrowConstraint.active = false
                self.halfShowingArrowConstraint.active = true
                self.heightOfMapConstraint.active = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }, completion: { finished in
                self.fullScreenMap = false
                self.locationManager.updateMapViewToFitAnnotations(self.myMap)
        })
    }
    
    func slideOnTap(s: UITapGestureRecognizer){
        if(!fullScreenMap){
            slideDownAnimation()
        }
        else{
            slideUpAnimation()
        }
    }
    
    func exit(e: UITapGestureRecognizer){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateMapViewEvents(){
        self.dayEvents = calendarManager.getEventsForDate(self.dateBeingViewed!)
        for event in dayEvents{
            let coords = calendarManager.getEventLocationCoords(event)?.geoLocation
            if let latitude = coords?.coordinate.latitude{
                if let longitude = coords?.coordinate.longitude{
                    let pinLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
                    let objectAnnotation = MKPointAnnotation()
                    objectAnnotation.coordinate = pinLocation
                    objectAnnotation.title = event.title
                    myMap.addAnnotation(objectAnnotation)
                }
            }
        }
        self.locationManager.updateMapViewToFitAnnotations(self.myMap)
    }
    
    
    //TABLE VIEW FUNCTIONS
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        return (tableView.dequeueReusableCellWithIdentifier("EventCell") as? EventCell)!
    }
    
    func tableView(tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return self.dayEvents.count
    }
    
    
}
