//
//  SignUpViewController.swift
//  LunchApp
//
//  Created by Nathalie on 24/07/2023.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var passwordVisibilityButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var confirmPassword: UITextField!
    
    @IBOutlet weak var logInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        password.useUnderline()
        email.useUnderline()
        confirmPassword.useUnderline()
        signUpButton.layer.cornerRadius = 10
        logInButton.layer.cornerRadius = 10
        password.enablePasswordToggle()
        confirmPassword.enablePasswordToggle()
    }
    
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if email.text?.isEmpty == true {
            print("No text in email field")
            return
        }
        
        if password.text?.isEmpty == true {
            print("No text in password field")
            return
        }
        
        if password.text != confirmPassword.text {
            errorLabel.isHidden = false
            print("Passwords Don't Match!")
            errorLabel.text = "Passwords Don't Match!"
            return
        }
        signUp()
    }
    

    
    @IBAction func logInPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "logIn")
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    func signUp(){

        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { [self] (authResult, error) in
            guard let user = authResult?.user, error == nil else {
                Auth.auth().currentUser?.updateEmail(to: email.text!)
                Auth.auth().currentUser?.updatePassword(to: password.text!)
                errorLabel.isHidden = false
                errorLabel.text = error?.localizedDescription
                print("Error \(String(describing: error))")
                return
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "mainHome")
            vc.modalPresentationStyle = .overFullScreen
            present(vc, animated: true)
        }
 
    }

}
