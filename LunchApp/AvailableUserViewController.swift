//
//  AvailableUserViewController.swift
//  LunchApp
//
//  Created by Nathalie on 28/07/2023.
//

import UIKit
import FirebaseFirestore

class AvailableUserViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    var userId: String?
    let database = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textLabel.text = userId
        displayUserInfo()
    }

    func displayUserInfo() {
        
       // textLabel.text = "\(selectedUserName) is having food today at "
        
    }
}
