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
import MapKit

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var experiences: [Experience]?
    var plan: Plan?
    fileprivate var points: [MGLPointAnnotation]!
    fileprivate lazy var experiencePlaceDataSource = [String:Experience]()
    
    var shouldDownload: Bool = false
    var progressView: UIProgressView!

    let directions = Directions.sharedDirections
    var routeLine: MGLPolyline!
    var navAnnotation: MGLAnnotation!
    var navMode: Bool = false {
        didSet {
            cancelNavButton.isHidden = !navMode
            startNavButton.isHidden = !navMode
            centerViewButton.isHidden = navMode
            defaultViewButton.isHidden = navMode
            if navMode == false {
                navAnnotation = nil
            }
        }
    }
    lazy var startNavButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: self.view.bounds.height - 124, width: self.view.bounds.width, height: 60))
        button.setTitle("Start Navigation", for: UIControlState())
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = UIColor.plangoOrange()
        button.tintColor = UIColor.plangoOrange()
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapStartNav(_:)), for: .touchUpInside)
        return button
    }()
    lazy var cancelNavButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "close"), for: UIControlState())
        button.imageView?.contentMode = .center
        button.backgroundColor = UIColor.clear
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapCancelNav(_:)), for: .touchUpInside)
        return button
    }()
    lazy var centerViewButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 12, y: self.view.bounds.height - 130, width: 38, height: 38))
        button.setImage(UIImage(named: "center"), for: UIControlState())
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(didTapCenterView(_:)), for: .touchUpInside)

        return button
    }()
    lazy var defaultViewButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 12, y: self.view.bounds.height - 176, width: 38, height: 38))
//        button.contentHorizontalAlignment = .Fill
        button.setImage(UIImage(named: "allxp"), for: UIControlState())
//        button.contentMode = .ScaleToFill
        button.backgroundColor = UIColor.clear
        button.addTarget(self, action: #selector(didTapDefaultView(_:)), for: .touchUpInside)

        return button
    }()

    func didTapCancelNav(_ selector: UIButton) {
        endNavToAnnotation(mapView)
    }
    
    func didTapStartNav(_ selector: UIButton) {
        openAppleMapsNavForAnnotation(navAnnotation)
    }
    
    func didTapCenterView(_ selector: UIButton) {
        centerView()
    }
    
    func didTapDefaultView(_ selector: UIButton) {
        defaultView()
    }
    
    func centerView() {
        if let userLocation = mapView.userLocation {
            mapView.setCenter(userLocation.coordinate, zoomLevel: 14, animated: true)
        }
    }
    
    func defaultView() {
        if points.count == 1 {
            mapView.setCenter((points.first?.coordinate)!, zoomLevel: 14, animated: true)
        } else if points.count > 1 {
            mapView.showAnnotations(points, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] (notification) in
            if let map = self?.mapView {
                map.showsUserLocation = true //set location on after user possibly goes to settings and returns
            }
        }
        mapView = MGLMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.showsUserLocation = true

        if let userLocation = mapView.userLocation {
            mapView.setCenter(userLocation.coordinate, zoomLevel: 14, animated: false)
        }
        
        self.view.addSubview(mapView)
        
        let pointsAndPlaces = MapViewController.getPlacesFromExperiences(experiences)
        points = pointsAndPlaces.points
        experiencePlaceDataSource = pointsAndPlaces.places
        
        if points.count > 0 {
            mapView.addAnnotations(points)
            mapView.showAnnotations(points, animated: false)
        }
        
        if points.count == 1 {
            mapView.zoomLevel = 14
        }
        
        // Setup offline pack notification handlers.
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.offlinePackProgressDidChange(_:)), name: NSNotification.Name.MGLOfflinePackProgressChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveError(_:)), name: NSNotification.Name.MGLOfflinePackError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.offlinePackDidReceiveMaximumAllowedMapboxTiles(_:)), name: NSNotification.Name.MGLOfflinePackMaximumMapboxTilesReached, object: nil)
        
        //buttons
        view.addSubview(cancelNavButton)
        view.addSubview(startNavButton)
        view.addSubview(centerViewButton)
        view.addSubview(defaultViewButton)
    
        cancelNavButton.snp_makeConstraints { (make) in
            make.width.equalTo(50)
            make.height.equalTo(50)
            make.leading.equalTo(view.snp_leading)
            make.bottom.equalTo(startNavButton.snp_top)
        }
    }
    
//    override func viewDidDisappear(animated: Bool) {
//        super.viewDidDisappear(animated)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
//        
//    }
    
    deinit {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationDidBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    func startOfflinePackDownload() {
        // create region to save based on current map locations and also how far the user can zoom in
        let region = MGLTilePyramidOfflineRegion(styleURL: mapView.styleURL, bounds: mapView.visibleCoordinateBounds, fromZoomLevel: mapView.zoomLevel, toZoomLevel: mapView.zoomLevel + 4)
        
        guard let plan = plan else {return}
        //metadata for local storage
        let userInfo: NSDictionary = ["planID" : plan.id]
        let context = NSKeyedArchiver.archivedData(withRootObject: userInfo)
        
        //create and regsiter offline pack with the shared singleton storage object
        MGLOfflineStorage.shared().addPack(for: region, withContext: context) { (pack, error) in
            guard error == nil else {
                self.printError(error! as NSError)
                return
            }
            //start downloading
            pack?.resume()
        }
    }
    
    // MARK: - MGLOfflinePack notification handlers
    
    func offlinePackProgressDidChange(_ notification: Notification) {
        // Get the offline pack this notification is regarding,
        // and the associated user info for the pack; in this case, `name = My Offline Pack`
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String] {
            let progress = pack.progress
            // or notification.userInfo![MGLOfflinePackProgressUserInfoKey]!.MGLOfflinePackProgressValue
            let completedResources = progress.countOfResourcesCompleted
            let expectedResources = progress.countOfResourcesExpected
            
            // Calculate current progress percentage.
            let progressPercentage = Float(completedResources) / Float(expectedResources)
            
            // Setup the progress bar.
            if progressView == nil {
                progressView = UIProgressView(progressViewStyle: .default)
                let frame = view.bounds.size
                progressView.frame = CGRect(x: frame.width / 4, y: frame.height * 0.75, width: frame.width / 2, height: 10)
                view.addSubview(progressView)
            }
            
            progressView.progress = progressPercentage
            
            // If this pack has finished, print its size and resource count.
            if completedResources == expectedResources {
//                self.navigationController?.popViewControllerAnimated(true)
                progressView.isHidden = true
                self.mapView.imageToast(nil, image: UIImage(named: "whiteCheck")!, notify: false)
                
                let byteCount = ByteCountFormatter.string(fromByteCount: Int64(pack.progress.countOfBytesCompleted), countStyle: ByteCountFormatter.CountStyle.memory)
                print("Offline pack “\(userInfo["name"])” completed: \(byteCount), \(completedResources) resources")
            } else {
                // Otherwise, print download/verification progress.
                print("Offline pack “\(userInfo["name"])” has \(completedResources) of \(expectedResources) resources — \(progressPercentage * 100)%.")
            }
        }
    }
    
    func offlinePackDidReceiveError(_ notification: Notification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let error = notification.userInfo?[MGLOfflinePackErrorUserInfoKey] as? NSError {
            print("Offline pack “\(userInfo["name"])” received error: \(error.localizedFailureReason)")
        }
    }
    
    func offlinePackDidReceiveMaximumAllowedMapboxTiles(_ notification: Notification) {
        if let pack = notification.object as? MGLOfflinePack,
            let userInfo = NSKeyedUnarchiver.unarchiveObject(with: pack.context) as? [String: String],
            let maximumCount = (notification.userInfo?[MGLOfflinePackMaximumCountUserInfoKey] as AnyObject).uint64Value {
            print("Offline pack “\(userInfo["name"])” reached limit of \(maximumCount) tiles.")
        }
    }

    
    class func getPlacesFromExperiences(_ experiences: [Experience]?) -> (points: [MGLPointAnnotation], places: [String:Experience]) {
        var points = [MGLPointAnnotation]()
        var places = [String:Experience]()
        guard let experiences = experiences else {return (points, places)}
        
        for experience in experiences {
            guard let latitute: CLLocationDegrees = experience.geocode?.first else {continue}
            guard let longitute: CLLocationDegrees = experience.geocode?.last else {continue}
            
            let coordinates = CLLocationCoordinate2DMake(latitute, longitute)
            
            let point = MGLPointAnnotation()
            point.coordinate = coordinates

            if let details = experience.experienceDescription {
                point.subtitle = details
            }
            if let name = experience.name {
                point.title = name
                places[name] = experience
            }
            points.append(point)
        }
        return (points, places)
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        // Always try to show a callout when an annotation is tapped.
        return true
    }
    
    //customize annotation pin image
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        return nil
    }
    
    
//    func mapViewWillStartLocatingUser(mapView: MGLMapView) {
//        print("lat: \(mapView.userLocation?.coordinate.latitude) long: \(mapView.userLocation?.coordinate.longitude)")
//    }
    
    func mapView(_ mapView: MGLMapView, didFailToLocateUserWithError error: NSError) {
        if error.domain == kCLErrorDomain && error.code == CLError.Code.denied.rawValue {
            //the user denied access and should provide location
            DispatchQueue.main.async(execute: { () -> Void in
                let alert = UIAlertController(title: "Location Access Denied", message: "Go to settings to allow Plango to see your location", preferredStyle: .alert)
                
                let settings = UIAlertAction(title: "Settings", style: .default, handler: { (action) in
                    let url = URL(string: UIApplicationOpenSettingsURLString)
                    UIApplication.shared.openURL(url!)
                    
                })
                
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                alert.addAction(settings)
                self.present(alert, animated: true, completion: nil)
            })
        }
    }
    
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if points?.count == 1 {
            mapView.selectAnnotation(points!.first!, animated: true)
        }
        if shouldDownload == true {
            startOfflinePackDownload()
        }
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        guard annotation.coordinate.latitude != mapView.userLocation?.coordinate.latitude || annotation.coordinate.longitude != mapView.userLocation?.coordinate.longitude else { return nil }
        
        let directionsButton = UIButton(type: .detailDisclosure)
        directionsButton.setImage(UIImage(named: "directions"), for: UIControlState())
        return directionsButton
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        startNavToAnnotation(mapView, annotation: annotation)
    }
    
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        guard let title = annotation.title! else {return}
        guard let experience = experiencePlaceDataSource[title] else {return}
        
        let detailsVC = EventDetailsTableViewController()
        self.addChildViewController(detailsVC)
        detailsVC.experience = experience
        show(detailsVC, sender: nil)
    }
    
    func endNavToAnnotation(_ mapView: MGLMapView) {
        mapView.removeAnnotation(routeLine)
        routeLine = nil
        navMode = false
    }
    
    func openAppleMapsNavForAnnotation(_ annotation: MGLAnnotation) {
        
//        let regionDistance:CLLocationDistance = 10000
//        let regionSpan = MKCoordinateRegionMakeWithDistance(annotation.coordinate, regionDistance, regionDistance)
        
        let options = [
//            MKLaunchOptionsMapCenterKey: NSValue(MKCoordinate: regionSpan.center),
//            MKLaunchOptionsMapSpanKey: NSValue(MKCoordinateSpan: regionSpan.span),
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ]
        let placemark = MKPlacemark(coordinate: annotation.coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        if let name = annotation.title {
            mapItem.name = name
        }
        mapItem.openInMaps(launchOptions: options)
    }
    
    func startNavToAnnotation(_ mapView: MGLMapView, annotation: MGLAnnotation) {
        guard let userCoordinates = mapView.userLocation?.coordinate else {return}
        guard navMode == false else {return}
        
        let waypoints = [
            Waypoint(coordinate: userCoordinates),
            Waypoint(coordinate: annotation.coordinate),]
        
        let options = RouteOptions(waypoints: waypoints, profileIdentifier: MBDirectionsProfileIdentifierAutomobile)
        options.includesSteps = true
        
        directions.calculateDirections(options: options) { (waypoints, routes, error) in
            guard error == nil else {
                print("Error calculating directions: \(error!)")
                if error?.domain == MBDirectionsErrorDomain {
                    self.openAppleMapsNavForAnnotation(annotation)
                } else if error?.domain == NSURLErrorDomain {
                    self.view.detailToast("Navigation Unavailable", details: "Internet Connection Required for Navigation")
                }
                return
            }
            
            if let route = routes?.first, let leg = route.legs.first {
                print("Route via \(leg):")
                
                let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                
                let travelTimeFormatter = DateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .short
                let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
                
                print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                
                for step in leg.steps {
                    print("\(step.instructions)")
                    let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                    print("— \(formattedDistance) —")
                }
                
                if route.coordinateCount > 0 {
                    // Convert the route’s coordinates into a polyline.
                    var routeCoordinates = route.coordinates!
                    self.routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    // Add the polyline to the map and fit the viewport to the polyline.
                    mapView.addAnnotation(self.routeLine)
                    self.navAnnotation = annotation
                    self.navMode = true
                    let margins = UIEdgeInsetsMake(24, 24, 24, 24)
                    
                    mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: margins, animated: true)
                }
            }
        }

    }

}

//extension MGLTilePyramidOfflineRegion {
//    func applyToMapView(mapView: MGLMapView) {
//        mapView.styleURL = self.styleURL
//        mapView.setVisibleCoordinateBounds(self.bounds, animated: false)
//        mapView.zoomLevel = 14
//    }
//}
