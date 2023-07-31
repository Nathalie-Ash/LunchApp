//
//  HomeViewController.swift
//  LunchApp
//
//  Created by Nathalie on 26/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import DropDown

class HomeViewController: UIViewController {

    @IBOutlet weak var locationPicker: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var availabilitySwitch: UISwitch!
    @IBOutlet weak var restaurantDropDownMenu: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var usersTable: UITableView!

    let nameArray: [String] = ["Hadil", "Nathalie", "Raja"]

    let restDb = Firestore.firestore()
    let locDb = Firestore.firestore()
    
    let restaurantCollection = Firestore.firestore().collection("restaurants")
    let locationCollection = Firestore.firestore().collection("locations")

    let restaurantDropDown: DropDown = {
        let restaurantNames = DropDown()
        return restaurantNames
    } ()
    
    let locationDropDown: DropDown = {
        let location = DropDown()
        return location
    } ()
    
    
    var restaurants: [Restaurant] = []
    var location : [LunchLocation] = []
    var availableUsers: [String] = []
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupRestaurantDropDownMenu()
        setupLocationDropDownMenu()
        fetchAvailableUsersById()
    }
    
    func loadExistingRestaurants() {
        // Clear the existing restaurants array before adding new data
        self.restaurants.removeAll()

        for restaurantName in Restaurant.restaurants {
            let docRef = restaurantCollection.addDocument(data: ["name": restaurantName]) { error in
                if let error = error {
                    print("Error adding restaurant: \(error)")
                } else {
                    print("Restaurant added successfully!")
                }
            }
            
            // Generate the restaurant ID (document ID) for the struct
            let restaurant = Restaurant(restoID: docRef.documentID, name: restaurantName)
            self.restaurants.append(restaurant)
        }
    }

    
    func loadExistingLocations() {
        // Clear the existing restaurants array before adding new data
        self.location.removeAll()

        for locationName in LunchLocation.locations {
            let docRef = locationCollection.addDocument(data: ["name": locationName]) { error in
                if let error = error {
                    print("Error adding location: \(error)")
                } else {
                    print("Location added successfully!")
                }
            }
            
            // Generate the restaurant ID (document ID) for the struct
            let location = LunchLocation(locId: docRef.documentID, locName: locationName)
            self.location.append(location)
        }
    }

    func setupRestaurantDropDownMenu() {
        
        restaurantDropDown.anchorView = restaurantDropDownMenu
        restaurantDropDown.dataSource = Restaurant.restaurants

        restaurantDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.restaurantDropDownMenu.setTitle(item, for: .normal)
        }
    }
    
    func setupLocationDropDownMenu() {
        locationDropDown.anchorView = locationPicker
        locationDropDown.dataSource = LunchLocation.locations

        locationDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.locationPicker.setTitle(item, for: .normal)
        }

    }

    @IBAction func restaurantDropDownMenuTapped(_ sender: Any) {
          restaurantDropDown.show()
      }
    
    @IBAction func locationDropDownTapped(_ sender: UIButton) {
        locationDropDown.show()
    }
    

    @IBAction func submitButtonPressed(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

        let userId = uid
        let availability = availabilitySwitch.isOn
        let restoName = restaurantDropDownMenu.titleLabel?.text ?? ""
        var lunchTime = timePicker.date
        let location = locationPicker.titleLabel?.text ?? "Not Specified"
        let currentDate = Date()

        let userLunch = UserLunch(
            userId: userId,
            availability: availability,
            restoName: restoName,
            lunchTime: lunchTime,
            location: location,
            lunchDate: currentDate
        )

        let collection = Firestore.firestore().collection("userLunch")
        collection.document(uid).setData(userLunch.dictionary, merge: true) { error in
            if let error = error {
                print("Error adding user lunch data: \(error)")
            } else {
                print("User lunch data added successfully!")
            }
        }
        
        submitButton.backgroundColor = .green
    }

    func fetchAvailableUsersById() {
       
                let db = Firestore.firestore()
                let usersCollection = db.collection("userLunch")
               
                usersCollection.whereField("availability", isEqualTo: true).getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        return
                    }
                    
                    guard let querySnapshot = querySnapshot else {
                        print("QuerySnapshot is nil.")
                        return
                    }

                    var userIds: [String] = []
                    for document in querySnapshot.documents {
                        let userId = document.documentID
                        userIds.append(userId)
                     
                    }
                    
                    
                    print("Available users : \(userIds)")
                    
                    self.getUserNamesForUserIDs(userIDs: userIds)
                }
            }

    func getUserNamesForUserIDs(userIDs: [String]) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }

                let db = Firestore.firestore()
                let usersCollection = db.collection("users")

  
                usersCollection.getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error)")
                        return
                    }

                    guard let querySnapshot = querySnapshot else {
                        print("QuerySnapshot is nil.")
                        return
                    }

                    var userIds: [String] = []
                    for document in querySnapshot.documents {
                        let userId = document.documentID
                        userIds.append(userId)
                        
                    }

                    // Loop through the documents and extract user names
                    var userNames: [String] = []
                    for document in querySnapshot.documents {
                        if let username = document["name"] as? String {
                            userNames.append(username)
                            
                        }
                    }
                    if let currentUserIndex = userIds.firstIndex(of: uid) {
                              userNames.remove(at: currentUserIndex)
                          }
                    
                    self.availableUsers = userNames
                    self.usersTable.reloadData()
                 //   self.getUserNameForUserID(userID: uid)
                    print("User Names based on user IDs: \(userNames)")
                }
            }


}


extension HomeViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //where i put the data
        // create the cell and add the contents
        
        let element = self.availableUsers[indexPath.row]
        let cell = UITableViewCell()
        cell.textLabel?.text = element
        cell.textLabel?.textColor = .blue
        return cell
        
       
    }
    
    
    
}
