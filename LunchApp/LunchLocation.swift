//
//  LunchLocation.swift
//  LunchApp
//
//  Created by Nathalie on 27/07/2023.
//
//  user.swift
//  LunchApp
//
//  Created by Nathalie on 25/07/2023.
//


import Foundation
import Firebase
import FirebaseFirestore

struct LunchLocation {
    static let locations = [
        "Ktichen Block A", "High Tables", "Outside the Office", "Kitchen Block C", "Open Space", "No Preference"
    ]
    var locId: String
    var locName: String

    
    var dictionary: [String: Any] {
        return [
            "locName": locName
        ]
    }
}

extension LunchLocation {
  
    init?(dictionary: [String : Any]) {
        guard let locId = dictionary["locId"] as? String,
              let locName = dictionary["locName"] as? String else { return nil }
        
        self.init(locId: locId,
                  locName: locName )
    }
    
}




