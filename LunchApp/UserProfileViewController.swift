//
//  UserProfileViewController.swift
//  LunchApp
//
//  Created by Nathalie on 25/07/2023.
//

import UIKit
import FirebaseFirestore


class UserProfileViewController: UIViewController {

    @IBOutlet weak var nameLabel: UITextField!

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var officeLabel: UITextField!
    @IBOutlet weak var foodLabel: UITextField!
    @IBOutlet weak var restaurantLabel: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let name = nameLabel.text
        let birthday = datePicker.date
        let office = officeLabel.text
        let food = foodLabel.text
        let restaurant = restaurantLabel.text
        
        
        let collection = Firestore.firestore().collection("user")
       
        let user = User(
            name: name!,
          birthday: birthday,
          office: office!,
          food: food!,
          restaurant: restaurant!
        )

        collection.addDocument(data: user.dictionary)
    }
    

    @IBAction func savePressed(_ sender: UIButton) {
        
        
    }
    



}
