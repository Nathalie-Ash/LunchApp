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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let backButton = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = backButton
        
    
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

}
