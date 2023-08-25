//
//  ViewController.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 25.08.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedImage = ""
    var selectedImageId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        tableView.dataSource = self
        tableView.delegate = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonTapped))
        
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
        nameArray.removeAll()
        idArray.removeAll()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // Context.fetch icin gerekli bir request class'i ve result protokolu. (documentasyondan ulasabiliriz cont.fetch'de gerekli oldugunu gormek icin)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Images")
        // Core Data'nin cashe'dan okumamasi icin kullanilir, buyuk ve cok sayidaki veri saklamalarinda daha hizli geri donus almamiza olanak saglar
        //  True oldugunda (default hali truedur) tum veriler hata ateşlenene kadar satır önbelleğinde bulunur. Hata tetiklendiğinde, Core Data verileri satır önbelleğinden alır.
        fetchRequest.returnsObjectsAsFaults = false
        
        // Datalari fetch ile cekeriz | fetch getir demektir
        // Bu bir hata verebilecegi icin do catche ile yapacagiz
        // Ve bunu bir degiskene almamizdaki amac for loop ile bu datalarla tek tek islem yapabilmek icindir
        
        do {
            let results = try context.fetch(fetchRequest)
            // NSManagedObj: results'dan dizi olarak gelen datalari tek tek objelere ayirmak, ayiklamak icin kullanilir
            
            for result in results as! [NSManagedObject] {
                // Anahtar kelimeyi verip (ornek olmasi acisindan name verilmistir) AnyObj aliyoruz ve bunu String olark Cast etmeye calisiyoruz, casting olumsuz sonuclanirsa islem yapilamayacaktir
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "name") as? UUID {
                    self.idArray.append(id)
                }
             
                // Gelen yeni veri sonrasi table view guncellenir
                self.tableView.reloadData()
                    
            }
                    
                    
        } catch {
            print("Error in Data Fetch Resulst")
        }
        
    }
    
    
    @objc func addButtonTapped() {
        selectedImage = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    
    // Prepare ve DidSelectRow fonksiyonlari secilen image'larin bilgilerini detailsVC'da gostermede kullanacagiz. Yani 1 VC'yi hem kullanicidan girdi almak icin hem de daha once kaydedilen image'in bilgilerini yine ayni VC'da basmak icin kullanacagiz.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            // DetailsVC'yi degisken gibi kaydederiz
            let destinationVC = segue.destination as! DetailsVC
            // AnaVC'de olusturdugumuz property'lerimizi DetailsVC'deki property'lere atadik
            destinationVC.chosenImage = selectedImage
            destinationVC.chosenImageId = selectedImageId
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Eger bir image'e tiklandiysa o isme tiklandigini belirtiriz
        selectedImage = nameArray[indexPath.row]
        selectedImageId = idArray[indexPath.row]
        
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
}

