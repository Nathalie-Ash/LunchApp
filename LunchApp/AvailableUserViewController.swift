//
//  AvailableUserViewController.swift
//  LunchApp
//
//  Created by Nathalie on 28/07/2023.
//

import UIKit

class AvailableUserViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var backButton: UINavigationItem!
    
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let backButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
       
            displayUserInfo()
       
    }
    

    func displayUserInfo(){
        
       // textLabel.text = "\(selectedUserName) is having food today at "
        
    }

}
