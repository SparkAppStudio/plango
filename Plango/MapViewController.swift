//
//  MapViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 7/11/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Mapbox
import MapboxDirections

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var experiences: [Experience]?
    private var places: [MGLPointAnnotation]!
    
    let directions = Directions.sharedDirections

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self] (notification) in
            if let map = self?.mapView {
                map.showsUserLocation = true //set location on after user possibly goes to settings and returns
            }
        }

        mapView = MGLMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true

        if let userLocation = mapView.userLocation {
            mapView.setCenterCoordinate(userLocation.coordinate, zoomLevel: 14, animated: false)
        }
        
        self.view.addSubview(mapView)
        
        places = getPlacesFromExperiences(experiences)
        
        if places.count > 0 {
            mapView.addAnnotations(places)
            mapView.showAnnotations(places, animated: false)
        }
        
        if places.count == 1 {
            mapView.zoomLevel = 14
        }
        
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
//        
//    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func getPlacesFromExperiences(experiences: [Experience]?) -> [MGLPointAnnotation] {
        var points = [MGLPointAnnotation]()
        guard let experiences = experiences else {return points}
        
        for experience in experiences {
            guard let latitute: CLLocationDegrees = experience.geocode?.first else {break}
            guard let longitute: CLLocationDegrees = experience.geocode?.last else {break}
            
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            
            let point = MGLPointAnnotation()
            point.coordinate = coordinates
            if let name = experience.name {
                point.title = name
            }
            if let details = experience.experienceDescription {
                point.subtitle = details
            }
            points.append(point)
        }
        return points
    }

    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
        return true
    }
    
    //customize annotation pin image
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    
//    func mapViewWillStartLocatingUser(mapView: MGLMapView) {
//        print("lat: \(mapView.userLocation?.coordinate.latitude) long: \(mapView.userLocation?.coordinate.longitude)")
//    }
    
    func mapView(mapView: MGLMapView, didFailToLocateUserWithError error: NSError) {
        if error.domain == kCLErrorDomain && error.code == CLError.Denied.rawValue {
            //the user denied access and should provide location
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let alert = UIAlertController(title: "Location Access Denied", message: "Go to settings to allow Plango to see your location", preferredStyle: .Alert)
                
                let settings = UIAlertAction(title: "Settings", style: .Default, handler: { (action) in
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.sharedApplication().openURL(url!)
                    
                })
                
                let ok = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(ok)
                alert.addAction(settings)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    
    func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
        if places?.count == 1 {
            mapView.selectAnnotation(places!.first!, animated: true)
        }
    }
    
    func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
        
        guard let userCoordinates = mapView.userLocation?.coordinate else {return}
        
        let waypoints = [
            Waypoint(coordinate: userCoordinates),
            Waypoint(coordinate: annotation.coordinate),]
        
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifierAutomobile)
        options.includesSteps = true
        
        directions.calculateDirections(options: options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                return
            }
            
            if let route = routes?.first, leg = route.legs.first {
                print("Route via \(leg):")
                
                let distanceFormatter = NSLengthFormatter()
                let formattedDistance = distanceFormatter.stringFromMeters(route.distance)
                
                let travelTimeFormatter = NSDateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .Short
                let formattedTravelTime = travelTimeFormatter.stringFromTimeInterval(route.expectedTravelTime)
                
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                
                for step in leg.steps {
                    print("\(step.instructions)")
                    let formattedDistance = distanceFormatter.stringFromMeters(step.distance)
                    print("— \(formattedDistance) —")
                }
                
                if route.coordinateCount > 0 {
                    // Convert the route’s coordinates into a polyline.
                    var routeCoordinates = route.coordinates!
                    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    // Add the polyline to the map and fit the viewport to the polyline.
                    mapView.addAnnotation(routeLine)
                    
                    let margins = UIEdgeInsetsMake(24, 24, 24, 24)
                    
                    mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: margins, animated: true)
                }
            }
        }
        
        
    }

}
