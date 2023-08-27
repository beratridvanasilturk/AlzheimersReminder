//
//  LocationViewController.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 27.08.2023.
//

import UIKit
import MapKit
import CoreLocation

class LocationViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    //MARK: -Outlets
    @IBOutlet weak var mapView: MKMapView!
    // "CoreLocation Lokasyon Manageri" eklendi
    var locationManager = CLLocationManager()
    
    //MARK: -Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        locationManager.delegate = self
        // Kullanicinin lokasyonunun keskinligi (metre cinsi) belirlenir
        // Uygulamalarin amaclarina gore buradaki lokasyon sapmasi degisebilir ancak bizim projemizde en detayli konum bulmak hayati oneme sahiptir.
        // En detayli konum icin "kCLLocationAccuracyBest" kullanilir
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Kullanicidan izin istenir
        // Yine uygulamalarin amaclarina gore izin isteme sıklıgı degisebilir. Biz esnek davranip uygulama indirildiginde baslangicta bir kere sormayi tercih edecegiz.
        locationManager.requestAlwaysAuthorization()
        // Kullanicinin lokasyonu alinmaya baslanir.
        locationManager.startUpdatingLocation()
        
        
    }
}
