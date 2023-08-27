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
        
        // Gesture Recognizer'i burada haritaya pin eklemek icin kullanacagiz
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choseLocation(gestureRecognizer:)))
        
        // Kac saniye basildiktan sonra pin atacagimizi ayarlariz
        gestureRecognizer.minimumPressDuration = 3
        
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    // choseLocation'a input olarak UILongPressGestureRecognizer'i vermemizin amaci o fonksiyon icerisinde UILongPressGestureRecognizer'in ozelliklerine "." koyduktan sonra direkt kendi methodlarina kendi attributelerine ulasabilmek icindir.
    @objc func choseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        // Gesture Recognizer baslama durumunu kontrol eder
        if gestureRecognizer.state == .began {
            // Toucked point kullanicinin dokunmus oldugu noktanin lokasyonunu almak icin kullanilir
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            // Dokunulan point'i coordinate'a cevirir
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            // Olusturdugumuz pini nereye atamamiz gerektigini ayarliyoruz
            // Annotation: Pin
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = "New Annotation"
            annotation.subtitle = "Important Location"
            
            self.mapView.addAnnotation(annotation)
            
        }
        
        // DidUptadeLocations: Guncellenen lokasyonlari array icerisinde verern hazir functur
        // CLLocation enlem ve boylam icerir
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
            // Kullanicinin anlik lokasyonunu aliriz
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            // Lokasyonu gosterebilmek icin zoom seviyesi olusturmaliyiz
            // Span: yukseklik ve genislik yani zoom anlamina gelir
            // 0.02 degerleri ne kadar kuculurse o kadar yakinlastirilir
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            //  Region: Bolge anlamindadir, Bolge merkezini olusturdumuz lokasyona zoomunu da olusturdugumuz zoom'a atadik
            let region = MKCoordinateRegion(center: location, span: span)
            // Belirtilen enlem ve boylama yani bolgeye zoomlama islemini tamamlar
            mapView.setRegion(region, animated: true)
            
        }
    }
}
