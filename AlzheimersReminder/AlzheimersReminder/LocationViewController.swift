//
//  LocationViewController.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 27.08.2023.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class LocationViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    var chosenLocationTitle = ""
    var chosenLongitutePoint = Double()
    var chosenLatitudePoint = Double()
    
    @IBOutlet weak var locationTitleTextField: UITextField!
    
    @IBOutlet weak var locationSubtitleTextField: UITextField!
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
            
            // Core Dataya long ve latitude'u kaydetmek icin clasimizda birer degisken olusturup burdan aldigimiz long ve lat'leri o degiskene atar ve daha sonrasinda SaveButton'dan Core Data'ya aktaririz
            chosenLatitudePoint = touchedCoordinate.latitude
            chosenLongitutePoint = touchedCoordinate.longitude
            
            // Olusturdugumuz pini nereye atamamiz gerektigini ayarliyoruz
            // Annotation: Pin
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinate
            annotation.title = locationTitleTextField.text
            annotation.subtitle = locationSubtitleTextField.text
            
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
    @IBAction func saveButtonTapped(_ sender: Any) {
    
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "AlzheimersReminder", into: context)
        
        // Attributes
        
        newLocation.setValue(locationTitleTextField.text, forKey: "mapTitle")
        newLocation.setValue(locationSubtitleTextField.text, forKey: "mapSubtitle")
        newLocation.setValue(chosenLatitudePoint, forKey: "mapLatitude")
        newLocation.setValue(chosenLongitutePoint, forKey: "mapLongitude")
        newLocation.setValue(UUID(), forKey: "mapId")
        
        do {
            try context.save()
            print("Core Data Saving Success")
        } catch{
            print("Core Data Saving Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newDataFromLocation"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        
        print("LOCATION CORE DATA SAVING BASARILI !!")
    }
    
}
