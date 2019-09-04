//
//  MapsVC.swift
//  Trackr
//
//  Created by Fauzi Rizal on 27/08/19.
//  Copyright © 2019 Fauzi Rizal. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Foundation

class MapVC: UIViewController {
    
    var locationManager =  CLLocationManager()
    var myLoc: CLLocation!
    var anotherPeopleLoc: CLLocation!
    var anotherPeopleName: String!
    var annotation: MKPointAnnotation!
    
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // map view
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let center = CLLocationCoordinate2D(latitude: myLoc.coordinate.latitude, longitude: myLoc.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        
        map.mapType = .satelliteFlyover
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        
        self.map.setRegion(region, animated: true)
        
        
        getAnnotation()
    }
    
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension MapVC: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5, animations: {
                self.annotation.coordinate = locations.last!.coordinate
            }, completion: nil)
        }
    }
}

// MARK: - Map View
extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func getAnnotation() {
        let locValue = CLLocationCoordinate2D(latitude: myLoc.coordinate.latitude, longitude: myLoc.coordinate.longitude)
        annotation = MKPointAnnotation()
        annotation.coordinate = locValue
        annotation.title = "Your location"
        annotation.subtitle = "Current location"
        
        let anotherAnnotation = MKPointAnnotation()
        
        if anotherPeopleLoc == nil {
            map.addAnnotation(annotation)
        } else {
            anotherAnnotation.coordinate = CLLocationCoordinate2D(latitude: anotherPeopleLoc.coordinate.latitude, longitude: anotherPeopleLoc.coordinate.longitude)
            anotherAnnotation.title = "\(anotherPeopleName!)"
            anotherAnnotation.subtitle = "Last location"
            map.addAnnotation(annotation)
            map.addAnnotation(anotherAnnotation)
            map.addAnnotations([annotation, anotherAnnotation])
            
        }
        
        
        
    }
}
