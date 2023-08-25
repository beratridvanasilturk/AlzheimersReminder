//
//  DetailsVC.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 25.08.2023.
//

import UIKit

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
}
