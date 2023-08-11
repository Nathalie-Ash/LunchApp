//
//  AvailableUserViewController.swift
//  LunchApp
//
//  Created by Nathalie on 28/07/2023.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AvailableUserViewController: UIViewController {
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var pickedRestaurantViewContainer: UIView!
    @IBOutlet weak var pickedRestaurantLabel: UILabel!
    @IBOutlet weak var userDetailsCollectionView: UICollectionView!
    
    var userId: String?
    let database = Firestore.firestore()
    
    var name: String?
    var birthday: String?
    var team: String?
    var isPublic: Bool?
    var profilePictureUrl: String?
    
    var restoName: String?
    var lunchTime: Date?
    var lunchLocation: String?
    
    var displayedBirthday = "Birthday Not Available"
    var sections: [AvailableUserCollectionViewSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userProfile.roundedImage()
        userProfile.contentMode = .scaleToFill
        let nib = UINib(nibName: "UserDetailsCollectionViewCell", bundle: .main)
        userDetailsCollectionView.register(nib, forCellWithReuseIdentifier: "UserDetailsCollectionViewCellId")
        displayUserInfo {
            self.updateUserUI()
        }
    }
    
    
    
    func displayUserInfo(completion: @escaping () -> Void) {
        guard let userId = userId else { return }
        let usersCollection = Firestore.firestore().collection("users")
        let userLunchCollection = Firestore.firestore().collection("userLunch")
        var favoriteFoodSection = AvailableUserCollectionViewSection(headerTitle: "Favorite Food", detailsList: [])
        var favoriteRestaurantsSection = AvailableUserCollectionViewSection(headerTitle: "Favorite Restaurant", detailsList: [])
        
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
            self.userNameLabel.text = "\(user.name)"
            self.name = user.name
            self.birthday = user.birthday
            self.team = user.office
            self.isPublic = user.isPublic
            favoriteFoodSection.detailsList = user.food
            favoriteRestaurantsSection.detailsList = user.restaurant
            self.sections = [favoriteFoodSection, favoriteRestaurantsSection]
            
            let profilePictureURLString = user.profilePictureURL
            let profilePictureURL = URL(string: profilePictureURLString)
            guard let profilePictureURL = profilePictureURL else {
                return
            }
            do {
                let storageReference = try Storage.storage().reference(for: profilePictureURL)
                storageReference.getData(maxSize: 10 * 1024 * 1024) { data, error in
                    if let error = error {
                        print("Error fetching image data")
                        return
                    }
                    if let imageData = data, let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.userProfile.image = image
                        }
                    }
                }
            } catch {
                print(error)
            }
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
        guard let name = name, let birthday = birthday, let team = team, let restaurantName = restoName  else {
            //  textLabel.text = "User information not available."
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        if let date = dateFormatter.date(from: birthday){
            if  isPublic == true {
                dateFormatter.dateFormat = "MMMM d"
                displayedBirthday = dateFormatter.string(from: date)
            } else {
                displayedBirthday = "Birthday Not Available"
                
            }
        }
        
        guard let time = lunchTime else {
            return
        }
        dateFormatter.dateFormat = "HH:mm"
        let displayedTime = dateFormatter.string(from: time)
        
        
        
        self.userNameLabel.text = name
        self.birthdayLabel.text = displayedBirthday
        self.teamLabel.text = team
        self.timeLabel.text = displayedTime
        self.pickedRestaurantLabel.text = restaurantName
        self.nameLabel.text = "\(name) Lunch Time"
        self.userDetailsCollectionView.reloadData()
        
    }
    
}

extension AvailableUserViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        self.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.sections[section].detailsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserDetailsCollectionViewCellId", for: indexPath) as! UserDetailsCollectionViewCell
        cell.detailsLabel.text = sections[indexPath.section].detailsList[indexPath.row]
        return cell
    }
    
}


struct AvailableUserCollectionViewSection {
    
    let headerTitle: String
    var detailsList: [String] // in this case it's gonna be food or restaurant
    
}



