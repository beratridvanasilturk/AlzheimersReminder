//
//  ViewController.swift
//  AlzheimersReminder
//
//  Created by Berat Rıdvan Asiltürk on 25.08.2023.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonTapped))
    }
    
    @objc func addButtonTapped() {
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
}

