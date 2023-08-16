//
//  UserProfileViewController.swift
//  LunchApp
//
//  Created by Nathalie on 25/07/2023.
//

//TODO: fix labels for food and resto
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class UserProfileViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var officeLabel: UITextField!
    @IBOutlet weak var foodStackView: UIStackView!
    @IBOutlet weak var restaurantLabel: UITextField!
    @IBOutlet weak var publicInfoSwitch: UISwitch!
    @IBOutlet weak var profilePictureAvatar: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    @IBOutlet weak var foodChoice1: UITextField!
    @IBOutlet weak var foodChoice2: UITextField!
    @IBOutlet weak var foodChoice3: UITextField!
    
    @IBOutlet weak var restaurantChoice1: UITextField!
    
    @IBOutlet weak var restaurantChoice2: UITextField!
    
    @IBOutlet weak var restaurantChoice3: UITextField!
    
    var previousProfilePictureRef: StorageReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //profilePictureAvatar.roundedImage()
       // profilePictureAvatar.contentMode = .scaleToFill

        setUpProfilePicture()
        signOutButton.layer.cornerRadius = 10
        saveChangesButton.layer.cornerRadius = 10
        
        self.nameLabel.useUnderline()
        self.officeLabel.useUnderline()
        self.restaurantLabel.useUnderline()
        self.foodChoice1.useUnderline()
        self.foodChoice2.useUnderline()
        self.foodChoice3.useUnderline()
        
        self.restaurantChoice1.useUnderline()
        self.restaurantChoice2.useUnderline()
        self.restaurantChoice3.useUnderline()
        
        
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
                
                if user.food.count > 0, !user.food[0].isEmpty {
                         self.foodChoice1.text = user.food[0]
                     }
                     if user.food.count > 1, !user.food[1].isEmpty {
                         self.foodChoice2.text = user.food[1]
                     }
                     if user.food.count > 2, !user.food[2].isEmpty {
                         self.foodChoice3.text = user.food[2]
                     }
                
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
        
        
        if let foodChoice1Text = foodChoice1.text, !foodChoice1Text.isEmpty {
            favoriteFood.append(foodChoice1Text)
        }
        if let foodChoice2Text = foodChoice2.text, !foodChoice2Text.isEmpty {
            favoriteFood.append(foodChoice2Text)
        }
        if let foodChoice3Text = foodChoice3.text, !foodChoice3Text.isEmpty {
            favoriteFood.append(foodChoice3Text)
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
        profilePictureAvatar.contentMode = .scaleAspectFit
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
                        self.profilePictureAvatar.roundedImage()
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
            self.profilePictureAvatar.roundedImage()
          }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image = imageOriginal
            profilePictureAvatar.image = imageOriginal
            self.profilePictureAvatar.roundedImage()
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


extension UITextField {

    func useUnderline() {
        let border = CALayer()
        let borderWidth = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(origin: CGPoint(x: 0,y :self.frame.size.height - borderWidth), size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}
