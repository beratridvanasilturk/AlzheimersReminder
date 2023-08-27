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
        // Yine uygulamalarin amaclarina gore izin isteme sıklıgı degisebilir. Bu projede kullanicinin guvenligi icin "requestWhenInUseAuthorization" kullanacagiz ancak .plist'e bir uyari mesaji gondererek uygulama kullanilirken konuma surekli izin vermesi gerektigini hatirlatacagiz.
        locationManager.requestWhenInUseAuthorization()
        // Kullanicinin lokasyonu alinmaya baslanir.
        locationManager.startUpdatingLocation()
    }
    // DidUptadeLocations: Guncellenen lokasyonlari array icerisinde verern hazir functur
    // CLLocation enlem ve boylam icerir
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Kullanicinin anlik lokasyonunu aliriz
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        // Lokasyonu gosterebilmek icin zoom seviyesi olusturmaliyiz
        // Span: yukseklik ve genislik yani zoom anlamina gelir
        // 0.2 degerleri ne kadar kuculurse o kadar yakinlastirilir
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        //  Region: Bolge anlamindadir, Bolge merkezini olusturdumuz lokasyona zoomunu da olusturdugumuz zoom'a atadik
        let region = MKCoordinateRegion(center: location, span: span)
        // Belirtilen enlem ve boylama yani bolgeye zoomlama islemini tamamlar
        mapView.setRegion(region, animated: true)
        
    }
}
