//
//  DetailsVC.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 25.08.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: -Outlets
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK: - Variables
    var chosenImage = ""
    var chosenImageId : UUID?
    
    //MARK: - Funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.backgroundColor = .systemPurple.withAlphaComponent(0.7)
        name2TextField.backgroundColor = .systemGreen
        numberTextField.backgroundColor = .systemYellow
        
        if chosenImage != "" {
            
            // Detail ekraninda daha oncesinde kaydedilen gorsele tiklandiginda save butonunu gorunmez yapar
            saveButton.isHidden = true
            
            // Core Data'dan cekecegiz
            // Ilk olarak appDelegate'i cagirdik
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // Context'i (baglam) olusturduk
            let context = appDelegate.persistentContainer.viewContext
            
            // Entity name ve NsFetchRequestResult protocol'u ile fetchRequest olusturulur
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Entity")
            
            // Filtreleme islemi icin
            let idString = chosenImageId?.uuidString
            // Predicate bizim yazdigimiz kosulu bulup bize fetch eder
            // id = %@ : id'si virgulden sonraki argumana (idString'e) esit olan seyi bul anlamindadir
            // id yerine name getirmesini isteseydik ..format: "name = %@", self.chosenImage) yazardik. Biz ayni name'de birden fazla ornek olabilitesi acisindan proje basinda id'ye gore fetch etmeyi dusunduk.
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            // Verimi artirmak icin cache datalari duzenler
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            nameTextField.text = name
                        }
                        if let name2 = result.value(forKey: "name2") as? String {
                            name2TextField.text = name2
                        }
                        if let number = result.value(forKey: "number") as? Int {
                            numberTextField.text = String(number)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                    
                    
                }
                
            } catch {
                print("Error do-catch in DetailsVC")
                
            }
        }
            // if chosenImage != "" Degilse yani
            else {
                // Save button gorunur olsun
                saveButton.isHidden = false
                // Ama tiklanamasin. Yani daga image secilmeden button aktif hale gelmesin, image secildikten sonra tiklanabilir yapacagiz: imagePickerController'de
                saveButton.isEnabled = false
                
                nameTextField.text = ""
                name2TextField.text = ""
                numberTextField.text = ""
            }
        
        // Recognizer
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // View'in kendisine ekledik
        view.addGestureRecognizer(gestureRecognizer)
        
        // Kullanicinin gorsele tiklamasini duzenler
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    // Ui'da bosluga tiklayinca klavyeyi kapatma func
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    // Kullaniciyi galeriden image sectirme func
    @objc func selectImage() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        //  UIImagePickerControllerDelegate, UINavigationControllerDelegate classimiza eklendi. UINavContDelegate galeriden image sectikten sonra ekranin kapanmasinda ve tekrar uygulamaya donmekte kullanilacak.
        // Galeriye gidip image secme islemini yapar
        picker.sourceType = .photoLibrary
        // Kullanici sectigi image'i editleyebilmesini saglar
        picker.allowsEditing = true
        // picker'i present etmeliyiz
        present(picker, animated: true)
        
    }
    
    // Gorsel secildikten sonra image view'a gorselin aktarilmasini saglar
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // .editedImage yerine originalImage'i de kullanabilirdik. Genellikle ikisi kullanilir ama bu projede editi actigimiz icin editingImage daha saglikli olacaktir
        imageView.image = info[.editedImage] as? UIImage
        
        // Save button'u image secildikten sonra aktif hale getirdik
        saveButton.isEnabled = true
        
        self.dismiss(animated: true)
    }
    
    //MARK: - Actions
    // Core Data ile secilen image'i hafizaya atar
    @IBAction func askMarkTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Alert About Numbers!", message: "If you want to enter a phone number you can write without a space between numbers and without using a zero at the beginning.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // Bizim context'e ulasabilmemiz icin appdelegate'i bir degisken olarak atamamiz gerekir. Context: AppDelegate -> func saveContext
        // AppDelegate'i degisken olarak tanimladik
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // persistentContainer.viewContext ile AppDelegate'deki supporting context'leri kullanabilir hale geliriz
        let context = appDelegate.persistentContainer.viewContext
        // Entity name'i AlzheimersReminder.xcdatamodeld dosyasindaki basliktan aldik, veriyi nereye kaydececegimizi belirlemek icin kullandik NSEntityDescription.insertObj'yi
        let newImage = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: context)
        
        // Attributes
        // Attributeleri AlzheimersReminder.xcdatamodeld dosyasinda olusturdugumuz projemizde olmasini istedigimiz ozelliklerden aldik ki ona gore kaydetmek istedigimiz tum her seyi unique sekilde save edebilelim.
        newImage.setValue(nameTextField.text, forKey: "name")
        newImage.setValue(name2TextField.text, forKey: "name2")
        newImage.setValue(UUID(), forKey: "id")
        if let num = Int(numberTextField.text!) {
            newImage.setValue(num, forKey: "number")
            
        }
        // compressionQuality image'in kaydetme kalitesini duzenler, sıkıstırma islemidir.
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newImage.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Sucseed Image Save")
        } catch {
            print("Error: Image Save")
        }
        // Observer'lar icin (view controller arasi) mesaj yollama tool'udur,
        // Amacimiz eklenen image'i UITableView'de guncellemek icin notcenter kullanmaktir.
        // Burdan projemizdeki ViewController'a bir mesaj gondeririz (name: String ile) ve VC DetailVC'den aldigi mesajla ne yapmasi gerektigini anlar (biz projemizde get data func'u cagiracagiz) iki VC arasi bir cesit mektuplasma gibi dusunulebilir
        // Notification Center'a VC'da ViewWillAppear icerisinde cagirmaliyiz ki her vc'a donusde bu methodumuz tetiklensin, didLoad'da bunu basaramayiz.
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        
        // Bir onceki VC'a gecis icin kullanilir
        self.navigationController?.popViewController(animated: true)
    }
}
