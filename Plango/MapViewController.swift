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
    var plan: Plan?
    private var places: [MGLPointAnnotation]!
    private lazy var experiencePlaceDataSource = [String:Experience]()
    var shouldDownload: Bool = false
    
    let directions = Directions.sharedDirections
    var progressView: UIProgressView!

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
        
//        if Helper.isConnectedToNetwork() == false {
//            retrieveOfflineMap()
//        }

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
        
        // Setup offline pack notification handlers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.offlinePackProgressDidChange(_:)), name: MGLOfflinePackProgressChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveError(_:)), name: MGLOfflinePackErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveMaximumAllowedMapboxTiles(_:)), name: MGLOfflinePackMaximumMapboxTilesReachedNotification, object: nil)
    
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
//        
//    }
    
    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func retrieveOfflineMap() {
        guard let plan = plan else {return}
        for pack in MGLOfflineStorage.sharedOfflineStorage().packs! {
            guard let userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? NSDictionary else {continue}
            
            guard let planID = userInfo["planID"] as? String else {continue}
            if planID == plan.id {
                pack.region.performSelector(#selector(MGLTilePyramidOfflineRegion.applyToMapView(_:)), withObject: self.mapView)
                break
            }
            
        }
    }
    
    func startOfflinePackDownload() {
        // create region to save based on current map locations and also how far the user can zoom in
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: mapView.zoomLevel + 4)
        print(mapView.zoomLevel)
        guard let plan = plan else {return}
        //metadata for local storage
        let userInfo: NSDictionary = ["planID" : plan.id]
        let context = NSKeyedArchiver.archivedDataWithRootObject(userInfo)
        
        //create and regsiter offline pack with the shared singleton storage object
        MGLOfflineStorage.sharedOfflineStorage().addPackForRegion(region, withContext: context) { (pack, error) in
            guard error == nil else {
                self.printError(error!)
                return
            }
            //start downloading
            pack?.resume()
        }
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(notification: NSNotification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .Default)
                let frame = view.bounds.size
                progressView.frame = CGRectMake(frame.width / 4, frame.height * 0.75, frame.width / 2, 10)
                view.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
//                self.navigationController?.popViewControllerAnimated(true)
                let byteCount = NSByteCountFormatter.stringFromByteCount(Int64(pack.progress.countOfBytesCompleted), countStyle: NSByteCountFormatterCountStyle.Memory)
                print("Offline pack “\(userInfo["name"])” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"])” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    func offlinePackDidReceiveError(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String],
            error = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? NSError {
            print("Offline pack “\(userInfo["name"])” received error: \(error.localizedFailureReason)")
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(notification: NSNotification) {
        if let pack = notification.object as? MGLOfflinePack,
            userInfo = NSKeyedUnarchiver.unarchiveObjectWithData(pack.context) as? [String: String],
            maximumCount = notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey]?.unsignedLongLongValue {
            print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
        }
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

            if let details = experience.experienceDescription {
                point.subtitle = details
            }
            if let name = experience.name {
                point.title = name
                experiencePlaceDataSource[name] = experience
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
        if shouldDownload == true {
            startOfflinePackDownload()
        }
    }
    
    func mapView(mapView: MGLMapView, leftCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        let directionsButton = UIButton(type: .DetailDisclosure)
        directionsButton.setImage(UIImage(named: "directions"), forState: .Normal)
        return directionsButton
    }
    
    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        startNavToAnnotation(mapView, annotation: annotation)
    }
    
    func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
        //TODO: - show detail view of experience detail
        guard let title = annotation.title! else {return}
        guard let experience = experiencePlaceDataSource[title] else {return}
        
        let detailsVC = EventDetailsTableViewController()
        self.addChildViewController(detailsVC)
        detailsVC.experience = experience
        showViewController(detailsVC, sender: nil)
    }
    
    func startNavToAnnotation(mapView: MGLMapView, annotation: MGLAnnotation) {
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

extension MGLTilePyramidOfflineRegion {
    func applyToMapView(mapView: MGLMapView) {
        mapView.styleURL = self.styleURL
        mapView.setVisibleCoordinateBounds(self.bounds, animated: false)
        mapView.zoomLevel = 14
    }
}
