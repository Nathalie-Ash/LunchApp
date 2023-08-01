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
    
    var restaurantName: String?
    var lunchTime: Date?
    var lunchLocation: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let backButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
        
        displayUserInfo()
        
    }
    
    
    func displayUserInfo(){
        
        getUserInfoById(userId!)
        
        textLabel.text = ("\(name) is having lunch today at \(lunchTime) \n Restaurant Picked: \(restaurantName)")
        print()
        
    }
    
    func getUserInfoById(_ userId: String){
        let usersCollection = Firestore.firestore().collection("users")
        let userLunchCollection = Firestore.firestore().collection("userLunch")
        
      
        usersCollection.document(userId).getDocument { (querySnapshot, error) in
            if let error = error {
                return
            }
            guard let querySnapshot =  querySnapshot else { return }
            if let data = querySnapshot.data(), let user = User(dictionary: data) {
                self.name = user.name
                self.birthday = user.birthday
                self.team = user.office
                self.favFood = user.food
                self.favResto = user.restaurant
            }
        }
        
        userLunchCollection.document(userId).getDocument { (querySnapshot, error) in
            if let error = error {
                return
            }
            guard let querySnapshot =  querySnapshot else { return }
            if let data = querySnapshot.data(), let userLunch = UserLunch(dictionary: data) {
                self.restaurantName = userLunch.restoName
                self.lunchLocation = userLunch.location
                self.lunchTime = userLunch.lunchTime
            }
        }
    }
}


