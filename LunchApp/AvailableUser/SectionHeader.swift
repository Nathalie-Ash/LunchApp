//
//  SectionHeader.swift
//  LunchApp
//
//  Created by Nathalie on 14/08/2023.
//

import UIKit

class SectionHeader: UICollectionReusableView {
        
    @IBOutlet weak var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
       
    }
}
