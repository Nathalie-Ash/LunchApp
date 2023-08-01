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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayUserInfo { [weak self] in
                self?.updateUserUI()
              }
        displayUserLunchInfo { [weak self] in
                self?.updateUserLunchUI()
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
    }
    
    func displayUserLunchInfo(completion: @escaping () -> Void) {
            guard let userId = userId else { return }
            let userLunchCollection = Firestore.firestore().collection("userLunch")

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
//            self.lunchLocation = userLunch.location
//            self.lunchTime = userLunch.lunchTime
            
            // Call completion handler once user lunch information is fetched
            completion()
        }
    }
    
    func updateUserUI() {
           guard let name = name, let birthday = birthday, let team = team, let favFood = favFood,  let favResto = favResto else {
               textLabel.text = "User information not available."
               return
           }
           print("\(name) is having lunch today. Birthday: \(birthday). Office \(team). Fav Food: \(favFood). Fav Rest: \(favResto)")
        textLabel.text = "\(name) is having lunch today. Birthday: \(birthday). Office \(team). Fav Food: \(favFood). Fav Rest: \(favResto)"

       }
    
    func updateUserLunchUI() {
 
        guard let restaurantName = restoName else {
            textLabel.text = "Resto name not available"
            return
        }

//           let lunchTime = lunchTime
//           let dateFormatter = DateFormatter()
//           dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//           let formattedTime = dateFormatter.string(from: lunchTime)
           print("Restaurant name: \(restaurantName)")
        textLabel.text = "Restaurant name: \(restaurantName)"
       }
}


