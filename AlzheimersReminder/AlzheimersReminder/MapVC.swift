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
            
            // TIKLANAN YERIN ID'SINI VERIR
            let idString = selectedTitleId?.uuidString
            // Predicate bizim yazdigimiz kosulu bulup bize fetch eder
            // id = %@ : id'si virgulden sonraki argumana (idString'e) esit olan seyi bul anlamindadir
            // id yerine name getirmesini isteseydik ..format: "name = %@", self.chosenImage) yazardik. Biz ayni name'de birden fazla ornek olabilitesi acisindan proje basinda id'ye gore fetch etmeyi dusunduk.
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
                                         
                                         
                                         // Core Data'dan Annotation Pin Cekme Islemi Sonuclanir
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
    

        // MARK: TRUE
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

// choseLocation'a input olarak UILongPressGestureRecognizer'i vermemizin amaci o fonksiyon icerisinde UILongPressGestureRecognizer'in ozelliklerine "." koyduktan sonra direkt kendi methodlarina kendi attributelerine ulasabilmek icindir.
// MARK: TRUE
    @objc func choseLocation(gestureRecognizer: UILongPressGestureRecognizer) {
        // Gesture Recognizer baslama durumunu kontrol eder
        if gestureRecognizer.state == .began {
            // Toucked point kullanicinin dokunmus oldugu noktanin lokasyonunu almak icin kullanilir
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            // Dokunulan point'i coordinate'a cevirir
            let touchedCoordinate = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
            // CORE DATA'YA ENLEM BOYLAM ATAMAK ICIN DATAYI BURDAN CEKTIK
            // Core Dataya long ve latitude'u kaydetmek icin clasimizda birer degisken olusturup burdan aldigimiz long ve lat'leri o degiskene atar ve daha sonrasinda SaveButton'dan Core Data'ya aktaririz
            // Save Button Tapped ' da Attribute'lerde Core Data'ya Latitude ve Longitute Eklemek Ici Kullandik
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
        // Observer'lar icin (view controller arasi) mesaj yollama tool'udur,
        // Amacimiz eklenen image'i UITableView'de guncellemek icin notcenter kullanmaktir.
        // Burdan projemizdeki ViewController'a bir mesaj gondeririz (name: String ile) ve VC DetailVC'den aldigi mesajla ne yapmasi gerektigini anlar (biz projemizde get data func'u cagiracagiz) iki VC arasi bir cesit mektuplasma gibi dusunulebilir
        // Notification Center'a VC'da ViewWillAppear icerisinde cagirmaliyiz ki her vc'a donusde bu methodumuz tetiklensin, didLoad'da bunu basaramayiz.
        NotificationCenter.default.post(name: NSNotification.Name("newData2"), object: nil)
        
        // Bir onceki VC'a gecis icin kullanilir
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
