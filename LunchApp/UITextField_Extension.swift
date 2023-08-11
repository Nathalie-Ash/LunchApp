//
//  UITextField_Extension.swift
//  LunchApp
//
//  Created by Nathalie on 11/08/2023.
//

import Foundation
import UIKit

extension UITextField {
    
    func enablePasswordToggle() {

        let button = UIButton(type: .custom)
        self.setPasswordToggleImage(button)
        button.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
        button.tintColor = UIColor(named: "LunchApp_Purple")
        self.rightView = button
        self.rightViewMode = .always

    }

    @IBAction func togglePasswordView(_ sender: Any) {

        self.isSecureTextEntry = !self.isSecureTextEntry
        self.setPasswordToggleImage(sender as! UIButton)
    }


    fileprivate func setPasswordToggleImage(_ button: UIButton) {

        if (isSecureTextEntry) {
            button.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        }

    }

}
