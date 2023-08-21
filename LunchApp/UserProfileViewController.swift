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

    @IBOutlet weak var publicInfoSwitch: UISwitch!
    @IBOutlet weak var profilePictureAvatar: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    @IBOutlet weak var foodChoice: UITextField!
    @IBOutlet weak var addFoodChoiceButton: UIButton!
    
    @IBOutlet weak var foodChoicesStack: UIStackView!
    @IBOutlet weak var foodMessageLabel: UILabel!
    @IBOutlet weak var firstFoodChoice: UIButton!
    @IBOutlet weak var secondFoodChoice: UIButton!
    @IBOutlet weak var thirdFoodChoice: UIButton!
    
    @IBOutlet weak var restaurantChoice1: UITextField!
    
    var previousProfilePictureRef: StorageReference?
    
    var foodChoices: [String] = []
    var foodButtons: [UIButton] = []
    var initialButtonCenter: CGPoint = .zero
    
    @IBAction func addFoodChoice(_ sender: Any) {
        if let text = foodChoice.text, !text.isEmpty {
            if self.foodChoices.count < 3 {
                foodChoices.append(text)
                self.foodChoice.text = ""
                reloadFoodChoices()
            } else {
                self.foodMessageLabel.text = "You can only add 3 choices"
                self.foodMessageLabel.isHidden = false
            }
        }
    }
    
    @IBAction func removeFoodChoice1(_ sender: Any) {
        self.removeFoodChoice(at: 0)
    }
    
    @IBAction func removeFoodChoice2(_ sender: Any) {
        self.removeFoodChoice(at: 1)
    }
    
    @IBAction func removeFoodChoice3(_ sender: Any) {
        self.removeFoodChoice(at: 2)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpProfilePicture()
        signOutButton.layer.cornerRadius = 10
        saveChangesButton.layer.cornerRadius = 10
        
        self.nameLabel.useUnderline()
        self.officeLabel.useUnderline()
        self.restaurantChoice1.useUnderline()
        
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
                         self.foodChoice.text = user.food[0]
                     }
                
                if user.restaurant.count > 0, !user.restaurant[0].isEmpty {
                         self.restaurantChoice1.text = user.restaurant[0]
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
                

        isInfoPublic = !publicInfoSwitch.isOn
        
        favoriteFood = []
        if let foodChoiceText = foodChoice.text, !foodChoiceText.isEmpty {
            favoriteFood.append(foodChoiceText)
        }
        
        favoriteRestaurants = []
        if let restaurantChoice1Text = restaurantChoice1.text, !restaurantChoice1Text.isEmpty {
            favoriteRestaurants.append(restaurantChoice1Text)
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
        profilePictureAvatar.contentMode = .scaleAspectFill
        profilePictureAvatar.roundedImage()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        profilePictureAvatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker() {
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

//MARK: - Favorite Food
extension UserProfileViewController {
    
    func setupFavFood() {
        self.foodChoice.useUnderline()
        self.firstFoodChoice.isHidden = true
        self.secondFoodChoice.isHidden = true
        self.thirdFoodChoice.isHidden = true
        self.foodButtons = [self.firstFoodChoice, self.secondFoodChoice, self.thirdFoodChoice]
        self.foodMessageLabel.isHidden = true
        for button in foodButtons {
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            button.addGestureRecognizer(longPressGesture)
        }
    }
    
    func removeFoodChoice(at index: Int) {
        self.foodChoices.remove(at: index)
        self.reloadFoodChoices()
    }
    
    func reloadFoodChoices() {
        for (index, item) in foodChoices.enumerated() {
            let button = self.foodButtons[index]
            button.setTitle(item, for: .normal)
            button.isHidden = false
        }
        self.firstFoodChoice.isHidden = self.foodChoices.count == 0
        self.secondFoodChoice.isHidden = self.foodChoices.count < 2
        self.thirdFoodChoice.isHidden = self.foodChoices.count < 3
        self.foodChoicesStack.isHidden = self.firstFoodChoice.isHidden && self.secondFoodChoice.isHidden && self.thirdFoodChoice.isHidden
        self.foodMessageLabel.isHidden = true
    }
    
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began, let button = gesture.view as? UIButton {
            wiggleButton(button) {
                guard let index = self.foodButtons.firstIndex(where: { $0 == button }) else { return }
                self.removeFoodChoice(at: index)
            }
       }
    }
    
    func wiggleButton(_ button: UIButton, completion: @escaping () -> Void) {
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.08
            animation.repeatCount = 3
            animation.autoreverses = true
            animation.fromValue = NSValue(cgPoint: CGPoint(x: button.center.x - 10, y: button.center.y))
            animation.toValue = NSValue(cgPoint: CGPoint(x: button.center.x + 10, y: button.center.y))
            
            button.layer.add(animation, forKey: "wiggle")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + animation.duration * Double(animation.repeatCount)) {
                completion()
            }
        }
}
