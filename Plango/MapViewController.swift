//
//  MapViewController.swift
//  Plango
//
//  Created by Douglas Hewitt on 7/11/16.
//  Copyright © 2016 madebydouglas. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var experiences: [Experience]?
    private var places: [MGLPointAnnotation]!

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MGLMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        mapView.delegate = self
        
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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mapView.showsUserLocation = true
    }
    
    func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
        if places?.count == 1 {
            mapView.selectAnnotation(places!.first!, animated: true)
        }
    }

}
