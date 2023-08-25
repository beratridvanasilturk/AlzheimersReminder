//
//  DetailsVC.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 25.08.2023.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    var chosenImage = ""
    var chosenImageId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenImage != "" {
            // Core Data'dan cekecegiz
            
            
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
        self.dismiss(animated: true)
    }
    
    // Core Data ile secilen image'i hafizaya atar
    @IBAction func saveButtonTapped(_ sender: Any) {
        
        // Bizim context'e ulasabilmemiz icin appdelegate'i bir degisken olarak atamamiz gerekir. Context: AppDelegate -> func saveContext
        // AppDelegate'i degisken olarak tanimladik
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // persistentContainer.viewContext ile AppDelegate'deki supporting context'leri kullanabilir hale geliriz
        let context = appDelegate.persistentContainer.viewContext
        // Entity name'i AlzheimersReminder.xcdatamodeld dosyasindaki basliktan aldik, veriyi nereye kaydececegimizi belirlemek icin kullandik NSEntityDescription.insertObj'yi
        let newImage = NSEntityDescription.insertNewObject(forEntityName: "Images", into: context)
        
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
