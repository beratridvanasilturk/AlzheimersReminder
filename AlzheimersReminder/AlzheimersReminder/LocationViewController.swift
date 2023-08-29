//
//  LocationViewController.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 29.08.2023.
//

import UIKit
import CoreData

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: -Variables
    var locationArray = [String]()
    var idArray = [UUID]()
    
    
    var chosenLocationTitleId : UUID?
    var chosenLocationTitle = ""
    

    //MARK: - Funcs
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

  
        getData2()
    }
    
    
    
    // DetailsVC'den NotCenter ile gozlemci ekleyerek DetailsVC'den gelen mektuba gore yapilmasi gereken islemi bildirecegiz (getData'yi cagiracagiz)
    override func viewWillAppear(_ animated: Bool) {
        
        // newData mesajini gordugunde getData'yi cagirir
        // Yani kisaca eklenen image'i UI'da (UITableView'de) guncellemek icin notcenter kullandik
        NotificationCenter.default.addObserver(self, selector: #selector(getData2), name: NSNotification.Name(rawValue: "newData2"), object: nil)
    
    }
    
    
    
    
    
    
    // Core Data'dan Veri cekmede kullanilir
    @objc func getData2() {
        
        // Verileri viewWillAppear'da notCenter ile cekerken burada temizlemeden cifter cekme islemi yapiyor, bunun onune gecmek icin array'lari basta kaldiriyoruz
        locationArray.removeAll()
        idArray.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Context.fetch icin gerekli bir request class'i ve result protokolu. (documentasyondan ulasabiliriz cont.fetch'de gerekli oldugunu gormek icin)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
        // Core Data'nin cashe'dan okumamasi icin kullanilir, buyuk ve cok sayidaki veri saklamalarinda daha hizli geri donus almamiza olanak saglar
        //  True oldugunda (default hali truedur) tum veriler hata ateşlenene kadar satır önbelleğinde bulunur. Hata tetiklendiğinde, Core Data verileri satır önbelleğinden alır.
        fetchRequest.returnsObjectsAsFaults = false
        
        // Datalari fetch ile cekeriz | fetch getir demektir
        // Bu bir hata verebilecegi icin do catche ile yapacagiz
        // Ve bunu bir degiskene almamizdaki amac for loop ile bu datalarla tek tek islem yapabilmek icindir
        
        do {
            let results = try context.fetch(fetchRequest)
            // NSManagedObj: results'dan dizi olarak gelen datalari tek tek objelere ayirmak, ayiklamak icin kullanilir
            
            // Hic gorsel yokken hata almamak adina if kosulu bagladik
            if results.count > 0 {
                
                self.locationArray.removeAll()
                self.idArray.removeAll()
                
                for result in results as! [NSManagedObject] {
                    // Kullanmak istedigimiz anahtar kelimeyi verip karsiliginda bir AnyObj aliyoruz ve bunu String olark Cast etmeye calisiyoruz, casting olumsuz sonuclanirsa bu islem hic yapilamayacaktir
                    if let name = result.value(forKey: "title") as? String {
                        self.locationArray.append(name)
                    }
                
                    if let id2 = result.value(forKey: "id2") as? UUID {
                        self.idArray.append(id2)
                    }
                    
                    // Gelen yeni veri sonrasi table view guncellenir
                    self.tableView.reloadData()
                    
                }
            }
                    
        } catch {
            print("Error: Data Fetch Resulst in ViewController")
        }
        
    }
    
    
    
    
    
    // Prepare ve DidSelectRow fonksiyonlari secilen image'larin bilgilerini detailsVC'da gostermede kullanacagiz. Yani 1 VC'yi hem kullanicidan girdi almak icin hem de daha once kaydedilen image'in bilgilerini yine ayni VC'da basmak icin kullanacagiz.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapView" {
            // DetailsVC'yi degisken gibi kaydederiz
            let destinationVC = segue.destination as! MapVC
            // AnaVC'de olusturdugumuz property'lerimizi DetailsVC'deki property'lere atadik
            destinationVC.selectedTitle = chosenLocationTitle
            destinationVC.selectedTitleId = chosenLocationTitleId
            
            // LOCVC 'den MAPVC'ye Data Aktarimi Gerceklesmis Olur
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Eger bir image'e tiklandiysa o isme tiklandigini belirtiriz
        chosenLocationTitle = locationArray[indexPath.row]
        chosenLocationTitleId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toMapView", sender: nil)
    }
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = locationArray[indexPath.row]
        // Remove cell selection color
        cell.selectionStyle = .none
        return cell
    }
    

    
    
    @IBAction func addLocationTapped(_ sender: Any) {
        
        chosenLocationTitle = ""
        performSegue(withIdentifier: "toMapView", sender: nil)
        
    }
    
    
    
    // Swipe to Delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Core Data'dan  verileri bulup silmemiz gerekir
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            // Fetch request'in olusturulma amaci ilgili veriyi cekip silmek icindir
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
            // Predicate kullanim amaci sadece 1 veriyi silmek isteyisimiz, o veriyi bulup cekip silecegiz.
            // Nereye tiklandiysa onun id'sini bulmamizi saglar
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id2 = %@", idString)
            // Cachelarle ilgili uygulamaya hiz ve verim saglar
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
            let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                              
                    for result in results as! [NSManagedObject] {
                                  
                        if let id = result.value(forKey: "id2") as? UUID {
                            // Iki id'nin de birbirine esit olmasini saglama aliyoruz
                            if id == idArray[indexPath.row] {
                            // Core Data'dan result'u siler
                            context.delete(result)
                            locationArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            // TableView'i guncelleriz
                            self.tableView.reloadData()
                            
                            // Cora Data'da yapilan degisiklikleri kaydeder
                            do {
                                try context.save()
                                              
                            } catch {
                            print("error")
                                          }
                            // Eger aradigim seyi bulup sildiysem for loop'un devam etmesini kirmak icin kullandik
                            break
                            
                            }
                                      
                        }
                                  
                                  
                    }
                              
                              
                }
            } catch {
                print("error")
            }
        }
    }
    
    
}
