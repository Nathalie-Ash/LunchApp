//
//  UserProfileViewController.swift
//  LunchApp
//
//  Created by Nathalie on 25/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var officeLabel: UITextField!
    @IBOutlet weak var foodLabel: UITextField!
    @IBOutlet weak var restaurantLabel: UITextField!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var publicInfoSwitch: UISwitch!
    @IBOutlet weak var profilePictureAvatar: UIImageView!
      var choice = 1
    override func viewDidLoad() {        
        super.viewDidLoad()
        setUpProfilePicture()
    }
    
    
    // This array will hold the favorite food of the user
    // Maximum 3 values
    var favoriteFood: [String] = []
    // This array will hold the favorite restaurants of the user
    // Maximum 3 values
    var favoriteRestaurants: [String] = []
    
    var isInfoPublic : Bool = true
    var image: UIImage? = nil
    
    @IBAction func savePressed(_ sender: UIButton) {

        guard let image = profilePictureAvatar.image else { return }
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
 
        guard let name = nameLabel.text, !name.isEmpty,
              let office = officeLabel.text, !office.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }
        var profilePictureUrl = ""
        let birthday = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let formattedBirthday = dateFormatter.string(from: birthday)

        if publicInfoSwitch.isOn{
            isInfoPublic = false
        } else {
          isInfoPublic = true
        }
        
        self.uploadProfilePicture(image) { url in
            if let profilePictureURL = url {
                profilePictureUrl = profilePictureURL
            }
        }
            
            let user = User(
                userId: uid,
                name: name,
                birthday: formattedBirthday,
                office: office,
                food: self.favoriteFood,
                restaurant: self.favoriteRestaurants,
                isPublic: isInfoPublic,
                profilePictureURL: profilePictureUrl
            )
            
       
        
            let collection = Firestore.firestore().collection("users")
            collection.document(uid).setData(user.dictionary, merge: false) { error in
                print(error)
            }
     

          
           

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let mainTabBarController = storyboard.instantiateViewController(identifier: "mainHome") as? UITabBarController else {
            return
        }
        mainTabBarController.modalPresentationStyle = .fullScreen
        mainTabBarController.selectedIndex = 1 //index of the "Home" tab
        self.present(mainTabBarController, animated: true, completion: nil)
        }
        
        
    @IBAction func foodPlusButtonPressed(_ sender: UIButton) {
        guard self.favoriteFood.count < 3 else {
            showAlert(message: "A user can have a maximum of three values")
            return
        }
        guard let food = self.foodLabel.text, food.isEmpty == false else {
           showAlert(message: "Please Enter A Value.")
            return
        }
        while (choice < 4){
            choice += 1
            foodLabel.placeholder = "Choice \(choice)"

        }
        self.favoriteFood.append(food)
        self.foodLabel.text = ""
            
    }
    
    @IBAction func restaurantPlusButtonPressed(_ sender: UIButton) {
        
        guard self.favoriteRestaurants.count < 3 else {
            showAlert(message: "A user can have a maximum of three values")
            return
        }
        
        guard let restaurant = self.restaurantLabel.text, !restaurant.isEmpty else {
            showAlert(message: "Please A Value.")
            return
        }
        
        self.favoriteRestaurants.append(restaurant)
        self.restaurantLabel.text = ""
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "logIn")
                vc.modalPresentationStyle = .overFullScreen
                present(vc, animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }

    
    func showAlert(message: String) {
           let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alert, animated: true, completion: nil)
       }
    
    func setUpProfilePicture() {
        profilePictureAvatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        profilePictureAvatar.addGestureRecognizer(tapGesture)
    }
        
    @objc func presentPicker() {
//        profilePictureAvatar.layer.cornerRadius = 40
//        profilePictureAvatar.clipsToBounds = true
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    
    func uploadProfilePicture(_ image: UIImage, completion: @escaping ((_ url: String?) -> ())) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let storageRef = Storage.storage().reference().child("user \(uid)")

        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }

        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"

        let profilePicRef = storageRef.child("profilePictures").child("\(UUID().uuidString).jpg")

        profilePicRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                // Fetch the download URL for the uploaded image
                profilePicRef.downloadURL { url, error in
                    if let downloadURL = url?.absoluteString {
                        completion(downloadURL)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
    }

    
}


extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            image = imageSelected
            profilePictureAvatar.image = imageSelected
        }

        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageOriginal
            profilePictureAvatar.image = imageOriginal
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
}
