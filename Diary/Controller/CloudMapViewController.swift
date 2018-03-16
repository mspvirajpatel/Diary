//
//  CloudMapViewController.swift
//  Diary
//
//  Created by 牛苒 on 16/03/2018.
//  Copyright © 2018 牛苒. All rights reserved.
//

import UIKit
import MapKit
import CloudKit

class CloudMapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    
    var diary: CKRecord!
    var cllocation = CLLocation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.showsTraffic = true

        if let location = diary.object(forKey: "location") as? CLLocation {
            cllocation = location
        }
        // Add annotation
        let annotation = MKPointAnnotation()
        annotation.title = self.diary.object(forKey: "title") as? String
        annotation.subtitle = self.diary.object(forKey: "tag") as? String
        annotation.coordinate = cllocation.coordinate
        // Display the annotation
        self.mapView.showAnnotations([annotation], animated: true)
        self.mapView.selectAnnotation(annotation, animated: true)
    }

}
