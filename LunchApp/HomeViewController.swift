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
    
    
    let database = Firestore.firestore()
    
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
        updateListOfAvailableUsersFromListener()
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
        let currentDate = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)
        
        let userLunch = UserLunch(
            userId: userId,
            availability: availability,
            restoName: restoName,
            lunchTime: lunchTime,
            location: location,
            lunchDate: formattedDate
        )
        
        let collection = database.collection("userLunch")
        collection.document(uid).setData(userLunch.dictionary, merge: true) { error in
            if let error = error {
                print("Error adding user lunch data: \(error)")
            } else {
                
                print("User lunch data added successfully!")
            }
        }
        
        submitButton.backgroundColor = .green
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
        
        let today = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: today)
        
        database.collection("userLunch").whereField("lunchDate", isEqualTo: formattedDate)
            .addSnapshotListener { querySnapshot, error in
                guard let querySnapshot = querySnapshot else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                
                // Loop through each document in the userLunch collection
                self.availableRestaurants = []
                var uniqueRestaurants: Set<String> = []
                for document in querySnapshot.documents {
                    if let data = document.data() as? [String: Any],
                       let restaurantName = data["restoName"] as? String {
                        // Check if the restaurantName is not "No Preference"
                        if restaurantName != "No Preference"{
                            uniqueRestaurants.insert(restaurantName)
                        }
                    }
                }
                self.availableRestaurants = Array(uniqueRestaurants)
                self.restaurantsTable.reloadData()
            }
    }
    
    
    
    
    func fetchAllAvailableUserIdsFromListener(completion: @escaping ([String]) -> Void) {
        
        let today = Date.now
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedDate = dateFormatter.string(from: today)
        
        var userIds: [String] = []
        let usersCollection = database.collection("userLunch").whereField("lunchDate", isEqualTo: formattedDate).addSnapshotListener {  documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            for document in documentSnapshot.documents {
                if let data = document.data() as? [String: Any],
                   let availability = data["availability"] as? Bool {
                    if availability == true {
                        let userId = document.documentID
                        userIds.append(userId)
                    }
                }
            }
            completion(userIds)
        }
    }
    
    func fetchUserNameforUserIdsFromListener(for userIDs: [String], completion: @escaping ([String: String]) -> Void)  {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        
        let usersCollection = database.collection("users").whereField(FieldPath.documentID(), in: userIDs).addSnapshotListener { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            var userDict: [String: String] = [:]
            for document in documentSnapshot.documents {
                if let data = document.data() as? [String: Any] {
                    let username = data["name"] as? String
                    let userId = document.documentID
                    userDict[userId] = username
                }
            }
            userDict.removeValue(forKey: uid)
            completion(userDict)
            
        }
    }
    
    func updateListOfAvailableUsersFromListener() {
        self.fetchAllAvailableUserIdsFromListener { userIds in
            self.fetchUserNameforUserIdsFromListener(for: userIds){ userDict in
                self.availableUsers = userDict
                self.usersTable.reloadData()
            }
        }
    }
    
    
}
