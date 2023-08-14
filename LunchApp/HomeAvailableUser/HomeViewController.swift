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
    
    @IBOutlet weak var availabilityCollectionView: UICollectionView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var restaurantLabel: UILabel!
    //    var currentUser: User?
    @IBOutlet weak var lunchView: UIView!
    
    var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    var timer  = Timer()
    
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
    var selectedRestaurantPreference: String = "No Preference"
    
    var sections: [HomeViewCollectionViewSection] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupRestaurantDropDownMenu()
        setupLocationDropDownMenu()
        updateListOfAvailableUsersFromListener()
        addPickedRestaurantsFromListener()
        getUserName()
        lunchView.layer.cornerRadius = 10
        restaurantDropDownMenu.layer.cornerRadius = 10
        locationView.layer.cornerRadius = 10
        locationPicker.layer.cornerRadius = 10
        submitButton.layer.cornerRadius = 10
        
        
        let nib = UINib(nibName: "AvaialbleUserCollectionViewCell", bundle: .main)
        
        availabilityCollectionView.register(nib, forCellWithReuseIdentifier: "AvailabilityCollectionViewCellId")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    func loadExistingRestaurants() {
        // Clear the existing restaurants array
        self.restaurants.removeAll()
        
        for restaurantName in Restaurant.restaurants {
            let docRef = restaurantCollection.addDocument(data: ["name": restaurantName]) { error in
                if let error = error {
                    print("Error adding restaurant: \(error)")
                } else {
                    print("Restaurant added successfully!")
                }
            }
            
            let restaurant = Restaurant(restoID: docRef.documentID, name: restaurantName)
            self.restaurants.append(restaurant)
        }
    }
    
    
    func loadExistingLocations() {
        self.location.removeAll()
        
        for locationName in LunchLocation.locations {
            let docRef = locationCollection.addDocument(data: ["name": locationName]) { error in
                if let error = error {
                    print("Error adding location: \(error)")
                } else {
                    print("Location added successfully!")
                }
            }
            
            let location = LunchLocation(locId: docRef.documentID, locName: locationName)
            self.location.append(location)
        }
    }
    
    func setupRestaurantDropDownMenu() {
        
        restaurantDropDown.anchorView = restaurantDropDownMenu
        restaurantDropDown.dataSource = Restaurant.restaurants
        restaurantDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.restaurantLabel.text = item
            //            self.restaurantDropDownMenu.setTitle(item, for: .normal)
                self.selectedRestaurantPreference = item
        }
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.restaurantDropDownMenuTapped))
        self.lunchView.addGestureRecognizer(tapGesture)
        
    }
    
    func setupLocationDropDownMenu() {
        locationDropDown.anchorView = locationPicker
        locationDropDown.dataSource = LunchLocation.locations
        
        locationDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.locationLabel.text = item
        }
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.locationDropDownTapped))
        self.locationView.addGestureRecognizer(tapGesture)
    }
    
   @IBAction @objc func restaurantDropDownMenuTapped(_ sender: Any) {
        restaurantDropDown.show()
    }
    
    @IBAction func locationDropDownTapped(_ sender: UIButton) {
        locationDropDown.show()
    }
    
    @IBAction @objc func submitButtonPressed(_ sender: Any) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let userId = uid
        let availability = availabilitySwitch.isOn
        let restoName = self.selectedRestaurantPreference
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
        submitButton.backgroundColor = UIColor(red: 253.0/255.0, green: 136.0/255.0, blue: 71.0/255.0, alpha: 1.0)
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            self.submitButton.backgroundColor = UIColor(red: 136.0/255.0, green: 126.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    func getUserName() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        database.collection("users").whereField("userId", isEqualTo: uid).addSnapshotListener {
            querySnapshot, error in
            guard let querySnapshot = querySnapshot else { return }
            for document in querySnapshot.documents {
                if let data = document.data() as? [String: Any],
                   let name = data["name"] as? String{
                    self.nameLabel.text = "Hi \(name),"
                }
            }
        }
    }

}


extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == usersTable {
            if self.availableUsers.isEmpty{
                return 1
            }else {
                return availableUsers.count
            }
        } else if tableView == restaurantsTable {
            return availableRestaurants.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView == usersTable {
//            if self.availableUsers.isEmpty {
//                let cell = UITableViewCell()
//                cell.textLabel?.text = "No available users yet "
//                cell.textLabel?.textColor = .gray
//                cell.selectionStyle = .none
//                return cell
//            } else {
//                let element = Array(self.availableUsers)
//                let name = element[indexPath.row].value
//                let cell = UITableViewCell()
//                cell.imageView?.image = UIImage(named: "profile")
//                cell.textLabel?.text = name
//                cell.textLabel?.textColor = .black
//                cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
//                cell.selectionStyle = .none
//                return cell
//            }
//        } else if tableView == restaurantsTable {
            let element = self.availableRestaurants[indexPath.row]
            let cell = UITableViewCell()
            cell.textLabel?.text = element
            cell.imageView?.image = UIImage(named: "food")
            cell.textLabel?.textColor = .black
            cell.selectionStyle = .none
//            return cell
//        }
        return UITableViewCell()
    }
    
   /* func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    }*/
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
                        if restaurantName != "No Preference" {
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
        
        if userIDs.isEmpty {
                completion([String: String]())
                return
            }
        
        var availableUsersSection = HomeViewCollectionViewSection(headerTitle: "People having lunch today", detailsList: [:])
        
        self.sections = [availableUsersSection]
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
            //availableUsersSection.detailsList = userDict
            self.sections[0].detailsList = userDict
            completion(userDict)
            
        }
    }
    
    func updateListOfAvailableUsersFromListener() {
        self.fetchAllAvailableUserIdsFromListener { userIds in
            self.fetchUserNameforUserIdsFromListener(for: userIds) { userDict in
                if userDict.isEmpty {
                    self.availabilityCollectionView.reloadData()
                } else {
                    self.availableUsers = userDict
                    
                    self.availabilityCollectionView.reloadData()
                }
            }
        }
    }
  
}



extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.sections[section].detailsList.keys.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvailabilityCollectionViewCellId", for: indexPath) as! AvaialbleUserCollectionViewCell
        
        let availableIds = Array(sections[indexPath.section].detailsList.keys)
        let name = sections[indexPath.section].detailsList[availableIds[indexPath.row]]
           cell.nameLabel.text = name
           return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "availableHeaderView", for: indexPath) as? availableSectionHeaderCollectionReusableView{
            sectionHeader.titleLabel.text = sections[indexPath.section].headerTitle
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
    
    
}



struct HomeViewCollectionViewSection {
    let headerTitle: String // contains title of the sections
    var detailsList: [String : String] // contains the users who are available on this day and the  restaurants that have been chosen for today
}




