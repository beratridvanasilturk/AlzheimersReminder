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
    var selectedImage = ""
    var selectedImageId : UUID?
    
    //MARK: - Funcs
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

    
        // Add Location Button
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addLocationTapped))
        
        getData()
    }
    
    
    
    // DetailsVC'den NotCenter ile gozlemci ekleyerek DetailsVC'den gelen mektuba gore yapilmasi gereken islemi bildirecegiz (getData'yi cagiracagiz)
    override func viewWillAppear(_ animated: Bool) {
        
        // newData mesajini gordugunde getData'yi cagirir
        // Yani kisaca eklenen image'i UI'da (UITableView'de) guncellemek icin notcenter kullandik
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    
    }
    
    
    
    
    
    
    // Core Data'dan Veri cekmede kullanilir
    @objc func getData() {
        
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
                for result in results as! [NSManagedObject] {
                    // Kullanmak istedigimiz anahtar kelimeyi verip karsiliginda bir AnyObj aliyoruz ve bunu String olark Cast etmeye calisiyoruz, casting olumsuz sonuclanirsa bu islem hic yapilamayacaktir
                    if let name = result.value(forKey: "title") as? String {
                        self.locationArray.append(name)
                    }
                    
                    if let name2 = result.value(forKey: "subtitle") as? String {
                        self.locationArray.append(name2)
                    }
                    
                    if let id = result.value(forKey: "id2") as? UUID {
                        self.idArray.append(id)
                    }
                    
                    // Gelen yeni veri sonrasi table view guncellenir
//                    self.tableView.reloadData()
                    
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
            destinationVC.chosenLocation = selectedImage
            destinationVC.chosenLocationId = selectedImageId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Eger bir image'e tiklandiysa o isme tiklandigini belirtiriz
        selectedImage = locationArray[indexPath.row]
        selectedImageId = idArray[indexPath.row]
        
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
    
    @objc func addLocationTapped() {
        
        performSegue(withIdentifier: "toMapView", sender: nil)
        
    }
    
    
    @IBAction func addLocationTapped2r(_ sender: Any) {
        
        
        performSegue(withIdentifier: "toMapView", sender: nil)
        
    }
    
    
    
}
