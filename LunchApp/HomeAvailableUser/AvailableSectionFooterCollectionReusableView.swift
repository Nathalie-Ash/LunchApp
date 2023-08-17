//
//  AvailableSectionFooterCollectionReusableView.swift
//  LunchApp
//
//  Created by Hadil Achkar on 17/08/2023.
//

import Foundation
import UIKit
class AvailableSectionFooterCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
}
