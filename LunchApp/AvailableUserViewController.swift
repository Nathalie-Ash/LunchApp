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
    
    var name: String?
    var birthday: String?
    var team: String?
    var favFood: [String]?
    var favResto: [String]?
    
    var restoName: String?
    var lunchTime: Date?
    var lunchLocation: String?
    
    var displayedBirthday = "Not specified"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayUserInfo {
            self.updateUserUI()
        }
    }
    
    
    
    func displayUserInfo(completion: @escaping () -> Void) {
        guard let userId = userId else { return }
        let usersCollection = Firestore.firestore().collection("users")
        let userLunchCollection = Firestore.firestore().collection("userLunch")
        
        usersCollection.document(userId).getDocument { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user info: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Error fetching user info")
                return
            }
            
            guard let data = querySnapshot.data() else {
                print("Failed to get data from querySnapshot")
                return
            }
            
            guard let user = User(dictionary: data) else {
                print("Failed to parse user data")
                return
            }
            
            self.name = user.name
            self.birthday = user.birthday
            self.team = user.office
            self.favFood = user.food
            self.favResto = user.restaurant
            
            completion()
        }
        
        userLunchCollection.document(userId).getDocument { (querySnapshot, error) in
            if let error = error {
                print("Error fetching user info: \(error)")
                return
            }
            guard let querySnapshot = querySnapshot else {
                print("Error fetching user info")
                return
            }
            
            guard let data = querySnapshot.data() else {
                print("Failed to get data from querySnapshot")
                return
            }
            
            guard let userLunch = UserLunch(dictionary: data) else {
                print("Failed to parse user lunch data")
                return
            }
            self.restoName = userLunch.restoName
            self.lunchLocation = userLunch.location
            self.lunchTime = userLunch.lunchTime
            
            completion()
        }
    }
    
    func updateUserUI() {
        guard let name = name, let birthday = birthday, let team = team, let favFood = favFood,  let favResto = favResto, let restaurantName = restoName  else {
            textLabel.text = "User information not available."
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        if let date = dateFormatter.date(from: birthday) {
            dateFormatter.dateFormat = "MMMM d"
            displayedBirthday = dateFormatter.string(from: date)
        } else {
            print("Invalid date format.")
        }
        
        let favFoodAsString = favFood.joined(separator: "-")
        let favRestoAsString = favResto.joined(separator: "-")
        
        
        textLabel.text = "\(name) is having lunch today at \(restaurantName).\n Birthday: \(displayedBirthday).\nTeam/Office: \(team).\n Fav Food: \(favFoodAsString).\n Fav Rest: \(favRestoAsString)"
    }
    
}


