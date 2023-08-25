//
//  DetailsVC.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 25.08.2023.
//

import UIKit

class DetailsVC: UIViewController {

    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        // View'in kendisine ekledik
        view.addGestureRecognizer(gestureRecognizer)

    }
    // Ui'da bosluga tiklayinca klavyeyi kapatma func
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
}
