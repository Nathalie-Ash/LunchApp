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

    @IBOutlet weak var userProfile: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var teamLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var pickedRestaurantViewContainer: UIView!
    @IBOutlet weak var pickedRestaurantLabel: UILabel!
    @IBOutlet weak var userDetailsCollectionView: UICollectionView!
    

    var userId: String?
    var currentUserId: String? 
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
    
    
    @IBAction func sendMessageButtonPressed(_ sender: UIButton) {

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let destinationViewController = storyboard.instantiateViewController(withIdentifier: "chatView") as? ChatViewController {
            destinationViewController.currentUserId = currentUserId
            destinationViewController.secondUserId = userId
            destinationViewController.modalPresentationStyle = .overFullScreen
            self.navigationController?.pushViewController(destinationViewController, animated: true)
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
            
            if (user.food.isEmpty){
                favoriteFoodSection.detailsList.append("Not Specified")
            } else {
                favoriteFoodSection.detailsList = user.food
            }
          
            
            if (user.restaurant.isEmpty){
                favoriteRestaurantsSection.detailsList.append("Not Specified")
            } else {
                favoriteRestaurantsSection.detailsList = user.restaurant
            }
            
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
        self.userDetailsCollectionView.reloadData()
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
        self.locationLabel.text = "Location: \(lunchLocation ?? "Not Specified")"
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
        
        if (self.sections[indexPath.section].detailsList.count == 0){
            cell.detailsLabel.text = "Not specified"
        } else {
            cell.detailsLabel.text = sections[indexPath.section].detailsList[indexPath.row]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as? SectionHeader{
            sectionHeader.titleLabel.text = sections[indexPath.section].headerTitle
            return sectionHeader
        }
        
        return UICollectionReusableView()
    }
    
    
    
}


struct AvailableUserCollectionViewSection {
    
    let headerTitle: String
    var detailsList: [String] // in this case it's gonna be food or restaurant
    
}



