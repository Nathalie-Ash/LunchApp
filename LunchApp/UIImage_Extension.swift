//
//  UIImage_Extension.swift
//  LunchApp
//
//  Created by Nathalie on 16/08/2023.
//

import Foundation
import UIKit


extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = (self.frame.size.height) / 2;
        self.clipsToBounds = true
    }
}
