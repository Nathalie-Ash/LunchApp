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
    
    var foodLabels: [UITextField] = []
    var restaurantLabels: [UITextField] = []
    var choice = 1
    
    @IBAction func savePressed(_ sender: UIButton) {

        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
 
        guard let name = nameLabel.text, !name.isEmpty,
              let office = officeLabel.text, !office.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }

        var foods: [String] = []
          for textField in foodLabels {
              if let text = textField.text, !text.isEmpty {
                  foods.append(text)
              }
          }
        var restaurants: [String] = []
          for textField in restaurantLabels {
              if let text = textField.text, !text.isEmpty {
                  restaurants.append(text)
                  }
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
                food: foods,
                restaurant: restaurants
            )
            
            let collection = Firestore.firestore().collection("users")
            collection.document(uid).setData(user.dictionary, merge: false) { error in
                print(error)
            }
        
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "mainHome")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
            
        }
        
        
        @IBAction func foodPlusButtonPressed(_ sender: UIButton) {
            choice += 1
            let newFoodLabel = createNewLabel()
            foodLabels.append(newFoodLabel)
            
            let index = foodLabels.count - 1
            if index == 0 {
                newFoodLabel.topAnchor.constraint(equalTo: foodLabel.bottomAnchor, constant: 10).isActive = true
                
            } else {
                let previousFoodLabel = foodLabels[index - 1]
                
                newFoodLabel.topAnchor.constraint(equalTo: foodLabel.bottomAnchor, constant: 10).isActive = true
                
            }
            
            newFoodLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        }
        
         func createNewLabel() -> UITextField {
            let newLabel = UITextField()
            newLabel.placeholder = "Choice \(choice)"
            newLabel.font = UIFont.systemFont(ofSize: 16)
            newLabel.borderStyle = .roundedRect
            newLabel.translatesAutoresizingMaskIntoConstraints = false
            return newLabel
        }
        
    func showAlert(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
        
    
}
