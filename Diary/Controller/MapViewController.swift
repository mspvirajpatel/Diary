//
//  MapViewController.swift
//  Diary
//
//  Created by 牛苒 on 2018/2/22.
//  Copyright © 2018年 牛苒. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    var diary: DiaryMO!
    var cllocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true
        
        // Json Decode the location information
        let jsonDecoder = JSONDecoder()
        if let location = diary.location {
            if let jsonData = location.data(using: .utf8) {
                do {
                    let userLocation = try jsonDecoder.decode(UserLocation.self, from: jsonData)
                    cllocation = CLLocation(coordinate: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude), altitude: userLocation.altitude, horizontalAccuracy: userLocation.horizontalAccuracy, verticalAccuracy: userLocation.verticalAccuracy, course: userLocation.course, speed: userLocation.speed, timestamp: diary.create!)
                } catch {
                    print(error)
                }
            }
        }
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.title = self.diary.title
        annotation.subtitle = self.diary.tag
        annotation.coordinate = cllocation.coordinate
        // Display the annotation
        self.mapView.showAnnotations([annotation], animated: true)
        self.mapView.selectAnnotation(annotation, animated: true)
    }
}

