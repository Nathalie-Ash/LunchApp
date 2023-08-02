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
    @IBOutlet weak var restaurantsTable: UITableView!
    
    // TODO: change name
    let db = Firestore.firestore()
    
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
    var availableUsers: [String: String] = [:]
    var availableRestaurants: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRestaurantDropDownMenu()
        setupLocationDropDownMenu()
        updateListOfAvailableUsers()
//        updateListOfAvailableRestaurants()
        addPickedRestaurantsFromListener()
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
        let lunchTime = timePicker.date
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
        
        let collection = db.collection("userLunch")
        collection.document(uid).setData(userLunch.dictionary, merge: true) { error in
            if let error = error {
                print("Error adding user lunch data: \(error)")
            } else {
                print("User lunch data added successfully!")
            }
        }
        
        submitButton.backgroundColor = .green
    }
    
    func fetchAllAvailableUserIds(completion: @escaping ([String]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        var userIds: [String] = []
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
            
            for document in querySnapshot.documents {
                let userId = document.documentID
                userIds.append(userId)
            }
            if let currentUserIndex = userIds.firstIndex(of: uid) {
                 userIds.remove(at: currentUserIndex)
            }
            completion(userIds)
        }
    }
    
    func fetchUserNameforUserIds(for userIDs: [String], completion: @escaping ([String: String]) -> Void)  {
        
        let usersCollection = db.collection("users")
        var userDict: [String: String] = [:]
        userIDs.forEach { userId in
            let query = usersCollection.whereField("userId", isEqualTo: userId).limit(to: 1)
            query.getDocuments { (querySnapshot,error) in
                guard let query = querySnapshot else { return }
                if let error = error {
                    
                } else {
                    let document1 = query.documents.first
                    let username = document1?["name"] as? String
                    userDict[userId] = username
                    completion(userDict)
                    print("Dictionary: \(userDict)")
                }
            }
        }
    }
    
    func updateListOfAvailableUsers() {
        self.fetchAllAvailableUserIds { userIds in
            self.fetchUserNameforUserIds(for: userIds) { userDict in
                self.availableUsers = userDict
                self.usersTable.reloadData()
            }
        }
    }
    
    func updateListOfAvailableRestaurants() {
        self.fetchRestaurantsFromUserLunch { resto in
            self.restaurantsTable.reloadData()
        }
    }
    
    func fetchRestaurantsFromUserLunch(completion: @escaping ([String]) -> Void) {
        let userLunchCollection = Firestore.firestore().collection("userLunch")
        
        userLunchCollection.getDocuments { (querySnapshot, error) in
            if let error = error {
                // Handle the error here if needed
                print("Error fetching user lunches: \(error)")
                completion([]) // Call the completion handler with an empty array if there's an error
                return
            }
            
            
            // Loop through each document in the userLunch collection
            for document in querySnapshot!.documents {
                if let data = document.data() as? [String: Any],
                   let restaurantName = data["restoName"] as? String {
                    // Add the restaurant name to the restaurants array
                    self.availableRestaurants.append(restaurantName)
                }
            }
            print("Restaurants: \(self.availableRestaurants)")
            // Call the completion handler with the array of restaurant names
            completion(self.availableRestaurants)
        }
    }
    
}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == usersTable {
            return availableUsers.count
        } else if tableView == restaurantsTable {
            return availableRestaurants.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == usersTable {
            let element = Array(self.availableUsers)
            let name = element[indexPath.row].value
            print(name)
            let cell = UITableViewCell()
            cell.textLabel?.text = name
            cell.textLabel?.textColor = .blue
            cell.selectionStyle = .none
            return cell
            
        } else if tableView == restaurantsTable {
            let element = self.availableRestaurants[indexPath.row]
            let cell = UITableViewCell()
            cell.textLabel?.text = element
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected user name from the availableUsers array
        if tableView == usersTable{
            let element = Array(self.availableUsers)
            let userId = element[indexPath.row].key
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "availableUser") as? AvailableUserViewController {
                
                destinationViewController.userId = userId
                destinationViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }
    }
}

// MARK: Firebase listeners
extension HomeViewController {
    
    func addPickedRestaurantsFromListener() {
        db.collection("userLunch")
            .addSnapshotListener { documentSnapshot, error in
                guard let documentSnapshot = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                // Loop through each document in the userLunch collection
                self.availableRestaurants = []
                for document in documentSnapshot.documents {
                    if let data = document.data() as? [String: Any],
                       let restaurantName = data["restoName"] as? String {
                        // Add the restaurant name to the restaurants array
                        self.availableRestaurants.append(restaurantName)
                        self.restaurantsTable.reloadData()
                    }
                }

            }
    }
    
}
