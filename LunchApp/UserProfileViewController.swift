//
//  UserProfileViewController.swift
//  LunchApp
//
//  Created by Nathalie on 25/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore


class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var officeLabel: UITextField!
    @IBOutlet weak var foodLabel: UITextField!
    @IBOutlet weak var restaurantLabel: UITextField!
    
    @IBOutlet weak var foodButton: UIButton!
    override func viewDidLoad() {        
        super.viewDidLoad()
    }
    
    
    // This array will hold the favorite food of the user
    // Maximum 3 values
    var favoriteFood: [String] = []
    // This array will hold the favorite restaurants of the user
    // Maximum 3 values
    var favoriteRestaurants: [String] = []
    
    @IBAction func savePressed(_ sender: UIButton) {

        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
 
        guard let name = nameLabel.text, !name.isEmpty,
              let office = officeLabel.text, !office.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }
        
        let birthday = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedBirthday = dateFormatter.string(from: birthday)

        if formattedBirthday.isEmpty {
            showAlert(message: "Please select a valid birthday.")
            return
        }
      
            let user = User(
                userId: uid,
                name: name,
                birthday: formattedBirthday,
                office: office,
                food: self.favoriteFood,
                restaurant: self.favoriteRestaurants
            )
            
            let collection = Firestore.firestore().collection("users")
            collection.document(uid).setData(user.dictionary, merge: false) { error in
                print(error)
            }
            
        }
        
        
    @IBAction func foodPlusButtonPressed(_ sender: UIButton) {
        guard self.favoriteFood.count < 3 else {
            showAlert(message: "A user can have a maximum of three values")
            return
        }
        guard let food = self.foodLabel.text, food.isEmpty == false else {
           showAlert(message: "Please Enter A Value.")
            return
        }
        self.favoriteFood.append(food)
        self.foodLabel.text = ""
            
    }
    
    @IBAction func restaurantPlusButtonPressed(_ sender: UIButton) {
        
        guard self.favoriteRestaurants.count < 3 else {
            showAlert(message: "A user can have a maximum of three values")
            return
        }
        
        guard let restaurant = self.restaurantLabel.text, !restaurant.isEmpty else {
            showAlert(message: "Please A Value.")
            return
        }
        
        self.favoriteRestaurants.append(restaurant)
        self.restaurantLabel.text = ""
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "logIn")
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    
    func showAlert(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    
    
        
    
}
