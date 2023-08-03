//
//  BirthdayTableViewCell.swift
//  LunchApp
//
//  Created by Nathalie on 03/08/2023.
//

import UIKit

class BirthdayTableViewCell: UITableViewCell {

    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var birthdayLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
