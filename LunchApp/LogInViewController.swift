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
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    // By adding this function, users who have longed in are always logged in even after they restart the app
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
    
//    func logIn(){
//
//        Auth.auth().signIn(withEmail: email.text! , password: password.text!) { [weak self] authResult, err  in
//            guard let strongSelf = self else {
//                return }
//            if let err = err {
//                print(err.localizedDescription)
//
//            }
//            self!.checkUserInfo()
//        }
//
//    }
    
 
    
    func logIn() {
        let userEmail = email.text!
        let userPassword = password.text!
        
        //check if the user is in the firebase authentication
        // it fetches the user by their email
        Auth.auth().fetchSignInMethods(forEmail: userEmail) { [weak self] signInMethods, error in
            guard let strongSelf = self else {
                return
            }
            
            // check if there was an error while fetching the user
            if let error = error {
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = "Error fetching sign-in methods: \(error.localizedDescription)"
                print("Error fetching sign-in methods: \(error.localizedDescription)")
                return
            }
            
            //checks if the sign in method contaings the emailPasswordAuthSignInMethod
            if let signInMethods = signInMethods, signInMethods.contains(EmailPasswordAuthSignInMethod) {
                // attempt to log in the user using the email and password
                // if the user exists 
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
    func checkUserInfo(){
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser?.uid)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "mainHome")
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
}
