//
//  HomeViewController.swift
//  LunchApp
//
//  Created by Nathalie on 26/07/2023.
//
//TODO: Add "No available users yet" and "No available restaurants yet" when details list is empty


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
    var availableRestaurants: [String: String] = [:]
    var selectedRestaurantPreference: String = "No Preference"
    
    var sections: [HomeViewCollectionViewSection] = []
    var availableRestaurantsSection = HomeViewCollectionViewSection(headerTitle: "Restaurants", detailsList: [:])
    var availableUsersSection = HomeViewCollectionViewSection(headerTitle: "People having lunch today", detailsList: [:])
    
    
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
        self.sections = [self.availableUsersSection, self.availableRestaurantsSection]
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
                
                
                var newAvailableRestaurants: [String: String] = [:]
                
                for document in querySnapshot.documents {
                    if let data = document.data() as? [String: Any],
                       let restaurantName = data["restoName"] as? String {
                        let restoId = document.documentID
                        
                        if restaurantName != "No Preference" && !newAvailableRestaurants.values.contains(restaurantName) {
                            newAvailableRestaurants[restoId] = restaurantName
                        }
                    }
                }
                
                self.availableRestaurants = newAvailableRestaurants
                self.sections[1].detailsList = self.availableRestaurants
                self.availabilityCollectionView.reloadData()
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
        
        if availableIds.isEmpty {
            cell.nameLabel.text = "Not available"
            print("Not available")
        } else {
            if let name = sections[indexPath.section].detailsList[availableIds[indexPath.row]] {
                cell.nameLabel.text = name
            } else {
                cell.nameLabel.text = "Name not found"
            }
        }
        
        return cell
    }


    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "availableHeaderView", for: indexPath) as? availableSectionHeaderCollectionReusableView{
            sectionHeader.titleLabel.text = sections[indexPath.section].headerTitle
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let availableIds = Array(sections[indexPath.section].detailsList.keys)
            let userId = availableIds[indexPath.row]
            let currentUserId =  Auth.auth().currentUser?.uid
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "availableUser") as? AvailableUserViewController {
                destinationViewController.currentUserId = currentUserId
                destinationViewController.userId = userId
                destinationViewController.modalPresentationStyle = .overFullScreen
                self.navigationController?.pushViewController(destinationViewController, animated: true)
            }
        }
    }
}



struct HomeViewCollectionViewSection {
    let headerTitle: String // contains title of the sections
    var detailsList: [String : String] // contains the users who are available on this day and the  restaurants that have been chosen for today
}




