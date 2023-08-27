//
//  LocationViewController.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 27.08.2023.
//

import UIKit
import MapKit

class LocationViewController: UIViewController,MKMapViewDelegate {
    //MARK: -Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: -Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
    }
}
