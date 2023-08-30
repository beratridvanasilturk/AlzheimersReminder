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

class MapVC: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {
    
    //MARK: -Variables
    var chosenLocationTitle = ""
    var chosenLongitutePoint = Double()
    var chosenLatitudePoint = Double()
    
    // Cell secildikten sonra MapVC'de secilen cell'in icerigini gostermek icin kullanilir
    var selectedTitle = ""
    var selectedTitleId : UUID?

    // Annotation'u Cora Data'dan Cekip Map'da Gostermek Icin Kullanacagiz
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitute = Double()
    var annotationLongitute = Double()
    
    // "CoreLocation Lokasyon Manageri" eklendi
    var locationManager = CLLocationManager()
    
    //MARK: -Outlets
    @IBOutlet weak var locationTitleTextField: UITextField!
    @IBOutlet weak var locationSubtitleTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: -Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTitleTextField.backgroundColor = .cyan.withAlphaComponent(0.7)
        locationSubtitleTextField.backgroundColor = .magenta.withAlphaComponent(0.6)
        
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
        gestureRecognizer.minimumPressDuration = 2
        
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != "" {
            
            // Core Data'dan Annotation'u Yani Pin'i cekecegiz
            // Ilk olarak appDelegate'i cagirdik
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // Context'i (baglam) olusturduk
            let context = appDelegate.persistentContainer.viewContext
            
            // Entity name ve NsFetchRequestResult protocol'u ile fetchRequest olusturulur
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
            
            // Tiklanan yerin id'sini verir, bu unique degeri kullanarak datalari fetch edecegiz.
            let idString = selectedTitleId?.uuidString
            
            // Predicate bizim yazdigimiz kosulu bulup bize fetch eder
            // id = %@ : id'si virgulden sonraki argumana (idString'e) esit olan seyi bul anlamindadir
            // id yerine title getirmesini isteseydik ..format: "title = %@", self.chosenLocationTitle) yazardik. Biz ayni title'de birden fazla ornek olabilitesi acisindan proje basinda id'ye gore fetch etmeyi dusunduk.
            fetchRequest.predicate = NSPredicate(format: "id2 = %@", idString!)
            
            // Verimi artirmak icin cache datalari duzenler
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subtitle
                                
                                if let latitude = result.value(forKey: "latitute") as? Double {
                                    annotationLatitute = latitude
                                    
                                    if let longitute = result.value(forKey: "longitute") as? Double{
                                        annotationLongitute = longitute
                                        
                                        // Eger tum degerler olduysa artik annotation'u olusturabiliriz
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitute, longitude: annotationLongitute)
                                        annotation.coordinate = coordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        
                                        locationTitleTextField.text = annotationTitle
                                        locationSubtitleTextField.text = annotationSubtitle
                                        
                                        // Lokasyonu guncellemeyi kullanici hareket etmesi olasiligina karsin durdurduk.
                                        locationManager.stopUpdatingLocation()
                                        // Boylelikle Core Data'dan Annotation Pin Cekme Islemi Sonuclanir
                                        
                                        // Secilen Annotation'a Zoom yapar
                                        // 6 kod yukardaki location'u alip span ile birlikte zoomda kullanacagiz
                                        let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        mapView.setRegion(region, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            } catch {
                print("Error do-catch in DetailsVC")
            }
        }
        else {
            // Secilen bir sey yoksa textfield'lari sifirlar
            locationTitleTextField.text = ""
            locationSubtitleTextField.text = ""
        }
    }
    
    // DidUptadeLocations: Guncellenen lokasyonlari array icerisinde verern hazir functur
    // CLLocation enlem ve boylam icerir
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Sadece Secilen Baslik Bos Ise Haritayi Gunceller, Boylelikle View DidLoad'daki Core Data'dan Alinan Annotation Gosterilirken Bir Yandan Da Hareketle Konumun Degismesi Engellenir
        if selectedTitle == "" {
            
            // Kullanicinin anlik lokasyonunu aliriz
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            // Lokasyonu gosterebilmek icin zoom seviyesi olusturmaliyiz
            // Span: yukseklik ve genislik yani zoom anlamina gelir
            // 0.04 degerleri ne kadar kuculurse o kadar yakinlastirilir
            let span = MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            //  Region: Bolge anlamindadir, Bolge merkezini olusturdumuz lokasyona zoomunu da olusturdugumuz zoom'a atadik
            let region = MKCoordinateRegion(center: location, span: span)
            // Belirtilen enlem ve boylama yani bolgeye zoomlama islemini tamamlar
            mapView.setRegion(region, animated: true)
        }
    }
    
    // choseLocation'a input olarak UILongPressGestureRecognizer'i vermemizin amaci o fonksiyon icerisinde UILongPressGestureRecognizer'in ozelliklerine "." koyduktan sonra direkt kendi methodlarina kendi attributelerine ulasabilmek icindir.
    @objc func choseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        
        // Gesture Recognizer baslama durumunu kontrol eder
        if gestureRecognizer.state == .began {
            
            // Toucked point kullanicinin dokunmus oldugu noktanin lokasyonunu almak icin kullanilir
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            
            // Dokunulan point'i coordinate'a cevirir
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            // Core Data'ya Enlem ve Boylam atamak icin burdan cekeriz gerekli bilgileri
            // Core Dataya long ve latitude'u kaydetmek icin clasimizda birer degisken olusturup burdan aldigimiz long ve lat'leri o degiskene atar ve daha sonrasinda SaveButton'dan Core Data'ya aktaririz
            // Save Button Tapped ' da Attribute'lerde Core Data'ya Latitude ve Longitute Eklemek Icin Kullandik
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
    }
    
    // Navigasyon ozelligi icin kullanilir, Core Data'daki annotationlara gitmek icin navigasyon gibi kullanacagiz. Harita icerisindeki pin yaninda ufak popup acip ona tiklayarak bulundugumuz konumdan o pin'e erismeyi planladik
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // annotation func girisinden aldik
        // MKUserLocation kullanicinin yerini pinle gosterir biz ise kullanicinin tikladigi yeri pin ile gostermek istiyoruz
        if annotation is MKUserLocation{
            return nil
        }
        
        // Bu yuzden yeni pin'i kendimiz olusturuyoruz
        let reUseId = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reUseId) as? MKMarkerAnnotationView
        
        if pinView == nil {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reUseId)
            // Callout baloncukla ekstra bilgl gosterebildigimiz yerdir
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
            
        } else {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Seperated Entity Names with Image View Cont (DetailVC)
        let newLocation = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context)
        
        // Attributes
        newLocation.setValue(locationTitleTextField.text, forKey: "title")
        newLocation.setValue(locationSubtitleTextField.text, forKey: "subtitle")
        
        // Enlem ve boylami chose location func'tan aliriz direkt
        newLocation.setValue(chosenLatitudePoint, forKey: "latitute")
        newLocation.setValue(chosenLongitutePoint, forKey: "longitute")
        
        newLocation.setValue(UUID(), forKey: "id2")
        
        do {
            try context.save()
            print("Core Data Saving Success")
        } catch{
            print("Core Data Saving Error")
        }
        // Not Center observer'lar icin (view controller arasi) mesaj yollama tool'udur,
        // Amacimiz eklenen yeri UITableView'de guncellemek icin notcenter kullanmaktir.
        // Burdan projemizdeki LocationViewController'a bir mesaj gondeririz (name: String ile) ve ana VC (locationlistVc) MapVC'den aldigi mesajla ne yapmasi gerektigini anlar (biz projemizde get data func'u cagiracagiz) iki VC arasi bir cesit mektuplasma gibi dusunulebilir
        // Notification Center'a LocationVC'da ViewWillAppear icerisinde cagirmaliyiz ki her vc'a donusde bu methodumuz tetiklensin, didLoad'da bunu basaramayiz.
        NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
        
        // Bir onceki VC'a gecis icin kullanilir
        self.navigationController?.popViewController(animated: true)
    }
    
    // Callout'a tiklandigini kontrol eden fonksiyondur
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if selectedTitle != "" {
            
            let requestLocation = CLLocation(latitude: annotationLatitute, longitude: annotationLongitute)
            
            // CLGeocoder: Coordinatlar ve yerler arasinda baglanti kurmada kullanilir
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                
                // Used Complation Handler
                if let placemark = placemarks {
                    
                    if placemark.count > 0 {
                        
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        
                        item.name = self.annotationTitle
                        
                        // MKLaunchOptionsDirectionsModeKey : Mode of transportation Hangi arac ile gosterilmesi istedigini belirler (Araba yuruyerek vs)
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking]
                        
                        item.openInMaps()
                    }
                }
            }
        }
    }
}
