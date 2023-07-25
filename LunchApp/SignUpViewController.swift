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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if email.text?.isEmpty == true {
            print("No text in email field")
            return
        }
        
        if password.text?.isEmpty == true {
            print("No text in password field")
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
                errorLabel.text = error?.localizedDescription
                errorLabel.isHidden = false
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
