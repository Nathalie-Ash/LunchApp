//
//  LogInViewController.swift
//  LunchApp
//
//  Created by Nathalie on 24/07/2023.
//

import UIKit
import FirebaseAuth

class LogInViewController: UIViewController {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var loggedInSwitch: UISwitch!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var logInButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        loggedInSwitch.isOn = UserDefaults.standard.bool(forKey: "StayLoggedIn")
        password.useUnderline()
        email.useUnderline()
        logInButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        password.enablePasswordToggle()
        
    }
    
   //  By adding this function, users who have longed in are always logged in even after they restart the app
//    override func viewDidAppear(_ animated: Bool) {
//        checkUserInfo()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "signUp")
//        vc.modalPresentationStyle = .overFullScreen
//        present(vc, animated: true)
//    }
//
    @IBAction func logInPressed(_ sender: UIButton) {
        validateFields()
    }
    
    @IBAction func createAccPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "signUp")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    //checks if the user has entered an input in both the email and the password fields
    func validateFields(){
        if email.text?.isEmpty == true {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "No text in email field"
            print("No text in email field")
            return
        }
        
        if password.text?.isEmpty == true {
            self.errorLabel.isHidden = false
            self.errorLabel.text = "No text in password field"
            print("No text in password field")
            return
        }
        logIn()
    }
     
    func logIn() {
        let userEmail = email.text!
        let userPassword = password.text!
        //check if the user is in the firebase authentication
        Auth.auth().fetchSignInMethods(forEmail: userEmail) { [weak self] signInMethods, error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = "Error fetching sign-in methods: \(error.localizedDescription)"
                print("Error fetching sign-in methods: \(error.localizedDescription)")
                return
            }
            
            //checks if the sign in method contaings the emailPasswordAuthSignInMethod
            if let signInMethods = signInMethods, signInMethods.contains(EmailPasswordAuthSignInMethod) {
                Auth.auth().signIn(withEmail: userEmail, password: userPassword) { authResult, error in
                    if let error = error {
                        self?.errorLabel.isHidden = false
                        self?.errorLabel.text = "Error logging in: \(error.localizedDescription)"
                        print("Error logging in: \(error.localizedDescription)")
                    } else {
                        // Login was  successful, navigate to main view
                        strongSelf.checkUserInfo()
                    }
                }
            } else {// if the user does not exist
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = "User with email '\(userEmail)' does not exist."
                print("User with email '\(userEmail)' does not exist.")
            }
        }
    }

    // checks if the user is currently logged in and navigates accordingly to
    // the main view
    func checkUserInfo() {
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.uid)
            // User is logged in, navigate to the main view.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mainTabBarController = storyboard.instantiateViewController(identifier: "mainHome") as? UITabBarController else {
                return
            }
            mainTabBarController.modalPresentationStyle = .fullScreen
            mainTabBarController.selectedIndex = 1 //index of the "Home" tab
            self.present(mainTabBarController, animated: true, completion: nil)
        } else {
            // User is not logged in, navigate to the login screen.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let loginViewController = storyboard.instantiateViewController(identifier: "logIn") as? LogInViewController else {
                return
            }
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true, completion: nil)
        }
    }
    
    @IBAction func stayLoggedInSwitchValueChanged(_ sender: UISwitch) {
            // Store the switch value in user defaults
            UserDefaults.standard.set(sender.isOn, forKey: "StayLoggedIn")
        }
    
    
    override func viewDidAppear(_ animated: Bool) {
        // Check if the user is already logged in and the stay logged in switch is on
        if let currentUser = Auth.auth().currentUser, loggedInSwitch.isOn {
            print(currentUser.uid)
            checkUserInfo()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyboard.instantiateViewController(identifier: "signUp") as? UITabBarController else {
                return
            }
            
            vc.modalPresentationStyle = .overFullScreen
            vc.selectedIndex = 1
            self.present(vc, animated: true, completion: nil)
        }

    }

    
}
