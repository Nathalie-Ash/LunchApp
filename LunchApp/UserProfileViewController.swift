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
    @IBOutlet weak var foodStackView: UIStackView!
    @IBOutlet weak var foodLabel: UITextField!
    @IBOutlet weak var restaurantLabel: UITextField!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var publicInfoSwitch: UISwitch!
    @IBOutlet weak var profilePictureAvatar: UIImageView!
    @IBOutlet weak var restaurantPlusButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    var foodChoice = 1
    var restChoice = 1
    var previousProfilePictureRef: StorageReference?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        profilePictureAvatar.roundedImage()
        profilePictureAvatar.contentMode = .scaleToFill
        setUpProfilePicture()
        signOutButton.layer.cornerRadius = 10
        saveChangesButton.layer.cornerRadius = 10
        foodButton.layer.cornerRadius = 10
        restaurantPlusButton.layer.cornerRadius = 10
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let usersCollection = Firestore.firestore().collection("users").document(uid).addSnapshotListener { documentSnapshot, error in
            guard let documentSnapshot = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            if let userData = documentSnapshot.data(),
               let user = User(dictionary: userData) {
                self.nameLabel.text = user.name
                self.officeLabel.text = user.office
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let birthdayString = user.birthday
                let birthdayDate = dateFormatter.date(from: birthdayString)
                self.datePicker.date = birthdayDate ?? Date()

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
                                self.profilePictureAvatar.image = image
                            }
                        }
                    }
                } catch {
                    print(error)
                }
            }
        }
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
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        guard let name = nameLabel.text, !name.isEmpty,
              let office = officeLabel.text, !office.isEmpty else {
            showAlert(message: "Please fill in all required fields.")
            return
        }
        
        let birthday = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedBirthday = dateFormatter.string(from: birthday)
        
        let minAllowedDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        
            if birthday < minAllowedDate! {
                self.datePicker.date = birthday
            } else {
                let alert = UIAlertController(title: "Age Constraint", message: "You must be at least 16 years old.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                     self.present(alert, animated: true, completion: nil)
                     self.datePicker.date = minAllowedDate!
                   return
               }
                

        if publicInfoSwitch.isOn{
            isInfoPublic = false
        } else {
            isInfoPublic = true
        }
        
        var user = User(
            userId: uid,
            name: name,
            birthday: formattedBirthday,
            office: office,
            food: self.favoriteFood,
            restaurant: self.favoriteRestaurants,
            isPublic: isInfoPublic,
            profilePictureURL: ""
        )
        
        
        if let image = profilePictureAvatar.image {
            self.uploadProfilePicture(image) { url in
                user.profilePictureURL = url ?? ""
                let collection = Firestore.firestore().collection("users")
                collection.document(uid).setData(user.dictionary, merge: true) { error in
                    print(error)
                }
            }
        } else {
            let collection = Firestore.firestore().collection("users")
            collection.document(uid).setData(user.dictionary, merge: true) { error in
                print(error)
            }
        }
        self.tabBarController?.selectedIndex = 1
        }
        
        
    @IBAction func foodPlusButtonPressed(_ sender: UIButton) {
        foodChoice += 1
        guard self.favoriteFood.count < 3 else {
            showAlert(message: "A user can have a maximum of three values")
            return
        }
        guard let food = self.foodLabel.text, food.isEmpty == false else {
            showAlert(message: "Please Enter A Value.")
            return
        }
        
        foodLabel.placeholder = "Choice \(foodChoice)"
//        let label = UILabel()
//        label.text = self.foodLabel.text
        self.favoriteFood.append(food)
        self.foodLabel.text = ""
//        self.foodStackView.addArrangedSubview(label)
        
        
    }
    
    @IBAction func restaurantPlusButtonPressed(_ sender: UIButton) {
        restChoice += 1
        guard self.favoriteRestaurants.count < 3 else {
            showAlert(message: "A user can have a maximum of three values")
            return
        }
        
        guard let restaurant = self.restaurantLabel.text, !restaurant.isEmpty else {
            showAlert(message: "Please A Value.")
            return
        }
        
        restaurantLabel.placeholder = "Choice \(restChoice)"
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
        
        // Delete previous profile picture if it exists
        if let previousProfilePictureRef = previousProfilePictureRef {
            previousProfilePictureRef.delete { error in
                if let error = error {
                    print("Error deleting previous profile picture: \(error)")
                }
            }
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        // create a reference to the users storage using UID
        let profilePicRef = storageRef.child("profilePictures").child("\(UUID().uuidString).jpg")
        
        previousProfilePictureRef = profilePicRef
        
        // upload the image to the specified path
        profilePicRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                // Fetch the download URL for the uploaded image
                profilePicRef.downloadURL { url, error in
                    // convert the URL into string
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


extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = (self.frame.size.height) / 2;
        self.clipsToBounds = true
    }
}
